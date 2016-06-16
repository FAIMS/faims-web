require Rails.root.join('lib/tasks/test_project_creator')
require Rails.root.join('app/models/modules/database')
require Rails.root.join('lib/tasks/modules')

begin
  namespace :modules do

    desc 'Clear all project modules'
    task :clear => :environment do
      clear_project_modules
    end

    desc 'Archive a specific or all project modules'
    task :archive => :environment do
      archive
    end

    desc 'Setup project module assets'
    task :setup => :environment do
      Database.generate_spatial_ref_list
      Database.generate_template_db
    end

    desc 'Create module from tarball'
    task :create => :environment do
      create_module
    end

    desc 'Delete module'
    task :delete => :environment do
      delete_module
    end

    desc 'Wipe a specific module including its files and database relationships'
    task :wipe => :environment do
      wipe_module
    end

    desc 'Undelete module'
    task :undelete => :environment do
      undelete_module
    end

    desc "Restore module from archive"
    task :restore => :environment do
      restore_module
    end

    desc "Upload module files"
    task :upload => :environment do
      upload_module_files
    end

    namespace :settings do

      desc "Change module client sponsor"
      task :client_sponsor => :environment do
        update_settings(:client_sponsor)
      end

      desc "Change module contact address"
      task :contact_address => :environment do
        update_settings(:contact_address)
      end

      desc "Change module copyright holder"
      task :copyright_holder => :environment do
        update_settings(:copyright_holder)
      end

      desc "Change module description"
      task :description => :environment do
        update_settings(:description)
      end

      desc "Change module has sensitive data"
      task :has_sensitive_data => :environment do
        update_settings(:has_sensitive_data)
      end

      desc "Change module land owner"
      task :land_owner => :environment do
        update_settings(:land_owner)
      end

      desc "Change module name or retrieve module name/keys"
      task :name => :environment do
        update_settings(:name)
      end

      desc "Change module participant"
      task :participant => :environment do
        update_settings(:participant)
      end

      desc "Change module permit holder"
      task :permit_holder => :environment do
        update_settings(:permit_holder)
      end

      desc "Change module permit issued by"
      task :permit_issued_by => :environment do
        update_settings(:permit_issued_by)
      end

      desc "Change module permit no"
      task :permit_no => :environment do
        update_settings(:permit_no)
      end

      desc "Change module permit type"
      task :permit_type => :environment do
        update_settings(:permit_type)
      end

      desc "Change module season"
      task :season => :environment do
        update_settings(:season)
      end

      desc "Change module SRID"
      task :srid => :environment do
        update_settings(:srid)
      end

      desc "Change module version"
      task :version => :environment do
        update_settings(:version)
      end

    end

    namespace :test do

      desc 'Generate test project modules'
      task :create, [:size] => :environment do |t, args|
        size = args[:size] || 50
        create_project_modules(size.to_i)
      end

    end

  end
rescue LoadError
  puts 'It looks like some Gems are missing: please run bundle install'
end
