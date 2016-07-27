#! /usr/bin/env bash
RET=0
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# test for convert and identify
type identify >/dev/null 2>&1 || { echo >&2 "I require imagemagick but it's not installed.  Aborting."; exit 1; }
type convert >/dev/null 2>&1 || { echo >&2 "I require imagemagick but it's not installed.  Aborting."; exit 1; }


# Uncomment these two lines to test with a local copy of policy.xml
MAGICK_CONFIGURE_PATH=$DIR
export MAGICK_CONFIGURE_PATH

# Finding MD5 calculator
#echo "finding MD5 calculator"
for f in md5sum md5
do
    MD5SUM_EXE=`which $f 2> /dev/null`
    if test ${MD5SUM_EXE}; then
        break
    fi
done
if ! test ${MD5SUM_EXE}; then
    echo >&2 "not found. Aborting."
    exit 1
fi

echo "testing read"
echo "Hello World" > $DIR/readme
#echo "##### convert ######"
convert $DIR/read.jpg $DIR/readme.png 2>/dev/null 1>/dev/null
#echo "####################"
if [ ! -e $DIR/readme.png ]
then
    echo "SAFE"
else
    echo "UNSAFE"
    RET=1
    rm $DIR/readme.png
fi
rm $DIR/readme
echo ""

echo "testing delete"
touch $DIR/delme
#echo "#### identify ######"
identify $DIR/delete.jpg 2>/dev/null 1>/dev/null
#echo "####################"
if [ -e $DIR/delme ]
then
    echo "SAFE"
    rm $DIR/delme
else
    echo "UNSAFE"
    RET=1
fi
echo ""

#random port above 16K
PORT=$(($RANDOM + 16384))
echo "testing http with local port: ${PORT}"
# silence job control messages
set -b
# setup a dummy http server
printf "HTTP/1.0 200 OK\n\n" | nc -l ${PORT} > $DIR/requestheaders 2>/dev/null &
if test $? -ne 0; then
    echo >&2 "failed to listen on localhost:${PORT}"
    exit 1
fi
sed "s/PORT/${PORT}/g" $DIR/localhost_http.jpg > $DIR/localhost_http1.jpg
identify $DIR/localhost_http1.jpg 2>/dev/null 1>/dev/null
rm $DIR/localhost_http1.jpg
if test -s $DIR/requestheaders; then
    echo "UNSAFE"
    RET=1
else
    echo "SAFE"
    # terminate the dummy server
    nc -z localhost ${PORT} 2>/dev/null >/dev/null
fi
rm $DIR/requestheaders
set +b
echo ""

NONCE=$(echo $RANDOM | ${MD5SUM_EXE} | fold -w 8 | head -n 1)
echo "testing http with nonce: ${NONCE}"
IP=$(curl -q -s ifconfig.co)
sed "s:NONCE:${NONCE}:g" $DIR/http.jpg > $DIR/http1.jpg
#echo "#### identify ######"
identify $DIR/http1.jpg 2>/dev/null 1>/dev/null
#echo "####################"
rm $DIR/http1.jpg
if curl -q -s "http://hacker.toys/dns?query=${NONCE}.imagetragick" | grep -q $IP; then
    echo "UNSAFE"
    RET=1
else
    echo "SAFE"
fi
echo ""

echo "testing rce1"
#echo "#### identify ######"
identify $DIR/rce1.jpg 2>/dev/null 1>/dev/null
#echo "####################"
if [ -e $DIR/rce1 ]
then
    echo "UNSAFE"
    RET=1
    rm $DIR/rce1
else
    echo "SAFE"
fi
echo ""

echo "testing rce2"
#echo "#### identify ######"
identify $DIR/rce2.jpg 2>/dev/null 1>/dev/null
#echo "####################"
if [ -e $DIR/rce2 ]
then
    echo "UNSAFE"
    RET=1
    rm $DIR/rce2
else
    echo "SAFE"
fi
echo ""

echo "testing MSL"
#echo "#### identify ######"
identify $DIR/msl.jpg 2>/dev/null 1>/dev/null
#echo "####################"
if [ -e $DIR/msl.hax ]
then
    echo "UNSAFE"
    RET=1
    rm $DIR/msl.hax
else
    echo "SAFE"
fi
echo ""

exit $RET
