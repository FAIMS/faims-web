#!/bin/bash



if lsb_release -rs | grep -q 18.04 ; then 
    echo "You're running 18.04, continuing... "
else
    echo "FAIMS 2.6 needs to be installed only on 18.04."
    exit 1
fi

if [[ $EUID -eq 0 ]]; then
    echo "This script should not be run using sudo or as the root user"
    exit 1
fi

APP_ROOT=/var/www/faims
BRANCH=2021-updates
# Update packages
sudo apt-get update

# Install common packages
sudo apt-get -y install git puppet=5.4.\* libreadline-dev software-properties-common

# Install puppet modules
if [ ! -d "$HOME/.puppet/modules/stdlib" ]; then
    puppet module install puppetlabs-stdlib
fi

if [ ! -d "$HOME/.puppet/modules/apt" ]; then
    puppet module install puppetlabs-apt
fi

if [ ! -d "$HOME/.puppet/modules/vcsrepo" ]; then
    puppet module install puppetlabs-vcsrepo
fi

# Clone webapp
if [ ! -d "$APP_ROOT" ]; then
    sudo git clone https://github.com/FAIMS/faims-web.git -b $BRANCH $APP_ROOT
    sudo chown -R $USER:$USER $APP_ROOT
    cd $APP_ROOT && git checkout $BRANCH
fi

if [ ! -h "/etc/puppet/hiera.yaml" ]; then
    sudo ln -s $APP_ROOT/puppet/hiera.yaml /etc/puppet/hiera.yaml
fi

# Configure puppet
sed -i "s/webapp_user:.*/webapp_user: $USER/g" $APP_ROOT/puppet/data/common.yaml
sed -i "s/app_tag:.*/app_tag: production/g" $APP_ROOT/puppet/data/common.yaml

# Update repo
sudo puppet apply $APP_ROOT/puppet/repo.pp --modulepath=$APP_ROOT/puppet/modules:$HOME/.puppet/modules

# Update server
sudo puppet apply $APP_ROOT/puppet/update.pp --modulepath=$APP_ROOT/puppet/modules:$HOME/.puppet/modules

# Test for and patch ImageTragic
pushd $APP_ROOT/tools/imagemagick-poc
./test.sh
case $? in
0)
    echo "System is not vulnerable to ImageTragic, leaving Imagemagick policy.xml as-in"
    ;;
1)
    echo "System is vulnerable to ImageTragic, replacing Imagemagick policy.xml"
    sudo mkdir -p /etc/ImageMagick
    sudo cp policy.xml /etc/ImageMagick/
    ;;
*)
    echo "Something went wrong testing for ImageTragic vulnerability"
esac
popd

# Restart services
sudo puppet apply $APP_ROOT/puppet/restart.pp --modulepath=$APP_ROOT/puppet/modules:$HOME/.puppet/modules
