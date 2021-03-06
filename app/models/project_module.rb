require Rails.root.join('app/models/modules/database')

class ProjectModule < ActiveRecord::Base
  include XSDValidator
  include MD5Checksum
  include SecurityHelper

  SETTINGS = 'settings'
  DB = 'db'
  DATA = 'data'
  APP = 'app'
  SERVER = 'server'

  class ProjectModuleException < Exception
  end

  DEFAULT_SRID = 4326

  # SCOPES

  default_scope order: 'name COLLATE NOCASE'
  default_scope where(deleted: false)

  scope :created, where(created: true, deleted: false)
  scope :deleted, where(deleted: true)

  attr_accessor :data_schema,
                :ui_schema,
                :ui_logic,
                :arch16n,
                :validation_schema,
                :css_style,
                :version,
                :srid,
                :season,
                :description,
                :permit_no,
                :permit_holder,
                :permit_issued_by,
                :permit_type,
                :contact_address,
                :participant,
                :copyright_holder,
                :client_sponsor,
                :land_owner,
                :has_sensitive_data,
                :tmpdir,
                :upgraded

  attr_accessible :name,
                  :key,
                  :created,
                  :data_schema,
                  :ui_schema,
                  :ui_logic,
                  :arch16n,
                  :validation_schema,
                  :css_style,
                  :version,
                  :srid,
                  :season,
                  :description,
                  :permit_no,
                  :permit_holder,
                  :permit_issued_by,
                  :permit_type,
                  :contact_address,
                  :participant,
                  :copyright_holder,
                  :client_sponsor,
                  :land_owner,
                  :has_sensitive_data,
                  :tmpdir

  validates :name, :presence => true, :length => {:maximum => 255},
            :format => {:with => /\A(\s*[^\/\\\?\%\*\:\|\"\'\<\>\.]+\s*)*\z/i} # do not allow file name reserved characters

  validates :key, :presence => true, :uniqueness => true

  has_many :project_module_exports
  has_many :project_module_processes
  has_many :user_modules
  has_many :users, :through => :user_modules
  has_many :background_jobs
  # Custom Validations

  def validate_validation_schema(schema)
    return if schema.blank?
    validate_schema('validation_schema', schema)

    begin
      DatabaseValidator.new(nil, schema.tempfile)
    rescue Exception => e
      logger.error e

      errors.add(:validation_schema, 'error initialising validation rules')
    end
  end

  def validate_data_schema(schema)
    return errors.add(:data_schema, "can't be blank") if schema.blank?
    validate_schema('data_schema', schema)
  end

  def validate_ui_schema(schema)
    return errors.add(:ui_schema, "can't be blank") if schema.blank?
    validate_schema('ui_schema', schema)
  end

  def validate_ui_logic(schema)
    return errors.add(:ui_logic, "can't be blank") if schema.blank?
  end

  def validate_css_style(schema)
    return if schema.blank?

    errors.add(:css_style, 'must be css file') unless schema.content_type =~ /css/
  end

  def validate_arch16n(arch16n)
    return if arch16n.blank?

    if arch16n.content_type =~ /gzip/
      tmp_dir = Dir.mktmpdir + '/'

      success = TarHelper.untar('zxf', arch16n.tempfile.to_path.to_s, tmp_dir)
      errors.add(:arch16n, 'invalid tarball file') and return unless success

      Dir.foreach(tmp_dir) do |file|
        next if file == '.' or file == '..'
        errors.add(:arch16n, 'must be .properties file: ' + file) and next if File.extname(file) != ".properties"
        validate_arch16n_file(File.join(tmp_dir, file))
      end
    else
      validate_arch16n_file(arch16n.tempfile)
    end
  end

  def validate_arch16n_file(file)
    begin
      line_num = 0
      File.open(file,'r').read.each_line do |line|
        line_num += 1
        next if line.blank?
        i = line.index('=')
        errors.add(:arch16n, "invalid properties file at line #{line_num} in #{File.basename(file)}") if !i
        errors.add(:arch16n, "invalid properties file at line #{line_num} in #{File.basename(file)}") if line[0..i] =~ /\s/
      end
    rescue Exception => e
      logger.error e

      errors.add(:arch16n, 'invalid properties file: ' + File.basename(file))
    end
  end

  # validation helper

  def validate_schema(attribute, schema)
    errors.add(attribute.to_sym, 'must be xml file') unless schema.content_type =~ /xml/

    begin
      xml_errors = XSDValidator.send("validate_#{attribute}", schema.tempfile.path)

      if xml_errors
        xml_errors.map do |x|
          errors.add(attribute.to_sym, "invalid xml at line #{x.line}")
        end
      end
    rescue => e
      errors.add(attribute.to_sym, e.message)
    end
  end

  after_initialize :init_file_map

  def init_file_map
    project_modules_dir = ProjectModule.project_modules_path
    uploads_dir = ProjectModule.uploads_path
    project_module_dir = project_modules_dir + "/#{key}/"
    n = name.gsub(/\s+/, '_') if name
    n ||= ''
    @file_map = {
        project_modules_dir: { name: 'project_modules', path: project_modules_dir },
        uploads_dir: { name: 'uploads', path: uploads_dir },
        project_module_dir: { name: key, path: project_module_dir },
        data_schema: { name: 'data_schema.xml', path: project_module_dir + 'data_schema.xml' },
        ui_schema: { name: 'ui_schema.xml', path: project_module_dir + 'ui_schema.xml' },
        ui_logic: { name: 'ui_logic.bsh', path: project_module_dir + 'ui_logic.bsh' },
        validation_schema: { name: 'validation_schema.xml', path: project_module_dir + 'validation_schema.xml' },
        css_style: { name: 'style.css', path: project_module_dir + 'style.css' },
        db: { name: 'db.sqlite3', path: project_module_dir + 'db.sqlite3' },
        settings: { name: 'module.settings', path: project_module_dir + 'module.settings' },
        properties: { name: 'faims.properties', path: project_module_dir + 'faims.properties' },
        files_dir: { name: 'files', path: project_module_dir + 'files/' },
        app_files_dir: { name: 'app', path: project_module_dir + 'files/app/' },
        server_files_dir: { name: 'server', path: project_module_dir + 'files/server/' },
        data_files_dir: { name: 'data', path: project_module_dir + 'files/data/' },
        tmp_dir: { name: 'tmp', path: project_module_dir + 'tmp/' },
        package_archive: { name: "#{n}.tar.bz2", path: project_module_dir + "tmp/#{n}.tar.bz2" },
    }
  end

  after_create :init_project_module

  def init_project_module
    FileUtils.mkdir_p @file_map[:project_modules_dir][:path] unless File.directory? @file_map[:project_modules_dir][:path]
    FileUtils.mkdir_p @file_map[:uploads_dir][:path] unless File.directory? @file_map[:uploads_dir][:path]
    FileUtils.mkdir_p @file_map[:project_module_dir][:path] unless File.directory? @file_map[:project_module_dir][:path]
    FileUtils.mkdir_p @file_map[:tmp_dir][:path] unless File.directory? @file_map[:tmp_dir][:path]
    FileUtils.mkdir_p @file_map[:server_files_dir][:path] unless File.directory? @file_map[:server_files_dir][:path]
    FileUtils.mkdir_p @file_map[:app_files_dir][:path] unless File.directory? @file_map[:app_files_dir][:path]
    FileUtils.mkdir_p @file_map[:data_files_dir][:path] unless File.directory? @file_map[:data_files_dir][:path]
  end

  before_destroy :cleanup_module

  def cleanup_module
    safe_delete_directory get_path(:project_module_dir)
  end

  # project module attributes

  def name
    read_attribute(:name)
  end

  def name=(value)
    write_attribute(:name, value.strip.squish) if value
  end

  def version
    get_settings['version'].nil? ? "" : get_settings['version']
  end

  def upgraded
    @upgraded
  end

  def upgraded=(value)
    @upgraded = value
  end

  # project_module database

  def db
    Database.new(self)
  end

  # project_module file name and path getters

  def get_name(symbol)
    @file_map[symbol][:name]
  end

  def get_path(symbol)
    @file_map[symbol][:path].to_s
  end

  # project_module file managers

  def settings_mgr
    return @settings_mgr if @settings_mgr
    @settings_mgr = FileManager.new(SETTINGS, get_path(:project_module_dir), get_path(:project_module_dir))
    @settings_mgr.add_file(get_path(:ui_schema))
    @settings_mgr.add_file(get_path(:ui_logic))
    @settings_mgr.add_file(get_path(:settings))
    Dir.glob(get_path(:project_module_dir) + "*.properties").each {|f| @settings_mgr.add_file(f)}
    @settings_mgr.add_file(get_path(:css_style)) if File.exists? get_path(:css_style)
    @settings_mgr
  end

  def db_mgr
    return @db_mgr if @db_mgr
    @db_mgr = FileManager.new(DB, get_path(:project_module_dir), get_path(:project_module_dir))
    @db_mgr.add_file(get_path(:db))
    @db_mgr
  end

  def server_mgr
    return @server_mgr if @server_mgr
    @server_mgr = FileManager.new(SERVER, get_path(:project_module_dir), get_path(:server_files_dir))
    @server_mgr.add_dir(get_path(:server_files_dir))
    @server_mgr
  end

  def app_mgr
    return @app_mgr if @app_mgr
    @app_mgr = FileManager.new(APP, get_path(:project_module_dir), get_path(:app_files_dir))
    @app_mgr.add_dir(get_path(:app_files_dir))
    @app_mgr
  end

  def data_mgr
    return @data_mgr if @data_mgr
    @data_mgr = FileManager.new(DATA, get_path(:project_module_dir), get_path(:data_files_dir))
    @data_mgr.add_dir(get_path(:data_files_dir))
    @data_mgr
  end

  def package_mgr
    return @package_mgr if @package_mgr
    @package_mgr = ArchiveManager.new('module', get_path(:project_module_dir), get_path(:project_module_dir),
                             'jcf', get_path(:package_archive), name.gsub(/\s/, '_'))
    @package_mgr.add_dir(get_path(:project_module_dir))
    @package_mgr.ignore_dir(get_path(:tmp_dir))
    @package_mgr
  end

  # lock management

  def with_shared_lock
    settings_mgr.wait_for_lock(File::LOCK_SH)
    server_mgr.wait_for_lock(File::LOCK_SH)
    app_mgr.wait_for_lock(File::LOCK_SH)
    data_mgr.wait_for_lock(File::LOCK_SH)
    db_mgr.wait_for_lock(File::LOCK_SH)
    return yield
  ensure
    settings_mgr.clear_lock
    server_mgr.clear_lock
    app_mgr.clear_lock
    data_mgr.clear_lock
    db_mgr.clear_lock
  end

  def with_exclusive_lock
    settings_mgr.wait_for_lock(File::LOCK_EX)
    server_mgr.wait_for_lock(File::LOCK_EX)
    app_mgr.wait_for_lock(File::LOCK_EX)
    data_mgr.wait_for_lock(File::LOCK_EX)
    db_mgr.wait_for_lock(File::LOCK_EX)
    return yield
  ensure
    settings_mgr.clear_lock
    server_mgr.clear_lock
    app_mgr.clear_lock
    data_mgr.clear_lock
    db_mgr.clear_lock
  end

  # project module android info

  def settings_info
    {
        files: file_mgr_info(settings_mgr, ''),
        dbVersion: db.current_version.to_s
    }
  end

  def settings_request_file(file)
    get_request_file(get_path(:project_module_dir), file)
  end

  def server_files_info
    {
        files: file_mgr_info(server_mgr, 'files/server/')
    }
  end

  def app_files_info
    {
        files: file_mgr_info(app_mgr, 'files/app/')
    }
  end

  def app_request_file(file)
    get_request_file(get_path(:app_files_dir), file)
  end

  def data_files_info
    {
        files: file_mgr_info(data_mgr, 'files/data/')
    }
  end

  def data_request_file(file)
    get_request_file(get_path(:data_files_dir), file)
  end

  # database use versions when sending info
  def db_version_file_name(from_version, to_version)
    "db_v#{from_version}-#{to_version}.sqlite"
  end

  def db_version_file_path(version_num = 0)
    version_num ||= 0
    File.join(get_path(:tmp_dir), db_version_file_name(version_num, db.current_version))
  end

  def db_version_invalid?(version_num)
    version_num ||= 0
    version_num = version_num.to_i
    version_num < 0 or version_num > db.current_version.to_i
  end

  def db_version_info(version_num = 0)
    version_num ||= 0
    full_path = db_version_file_path(version_num)
    {
      files: [{
                file: 'db.sqlite',
                size: File.size(full_path),
                md5: MD5Checksum.compute_checksum(full_path)
              }],
      dbVersion: db.current_version.to_s
    }
  end

  # file info helper function
  def file_mgr_info(file_mgr, remove_dir)
    db.get_files(file_mgr.name).map do |info|
      full_path = File.join(get_path(:project_module_dir), info[:filename])

      # update cache if file changed
      if File.mtime(full_path) > info[:timestamp]
        info = cache_file(file_mgr.name, File.join(full_path))
      end

      # get thumbnail file if thumbnail exists
      if info[:thumbnail_filename]
        {
            file: info[:thumbnail_filename].gsub(remove_dir, ''),
            size: info[:thumbnail_size],
            md5: info[:thumbnail_md5checksum]
        }
      else
        {
            file: info[:filename].gsub(remove_dir, ''),
            size: info[:size],
            md5: info[:md5checksum]
        }
      end
    end
  end

  def get_request_file(base_dir, file)
    request_file = File.join(base_dir, file)
    raise ProjectModuleException, 'file not found' unless File.exists? request_file
    request_file
  end

  def add_server_file(path, file)
    add_file(SERVER, get_path(:server_files_dir), path, file)
  end

  def add_app_file(path, file)
    add_file(APP, get_path(:app_files_dir), path, file)
    # need to cause database to sync
    db.insert_version(db.get_project_module_user_id(User.first ? User.first.email : 0)) # TODO which user to use?
  end

  def add_data_file(path, file)
    add_file!(DATA, get_path(:data_files_dir), path, file)
    # need to cause database to sync
    db.insert_version(db.get_project_module_user_id(User.first ? User.first.email : 0)) # TODO which user to use?
  end

  def remove_data_file(file)
    safe_delete_file file
    # remove file from cache
    db.delete_file file.to_s.gsub(get_path(:project_module_dir), '')
  end

  def add_file!(name, base_dir, path, file)
    raise ProjectModuleException, 'Filename is not valid.' unless is_valid_filename?(path)
    dest_path = File.join(base_dir, path)
    raise ProjectModuleException, 'File already exists.' if File.exists? dest_path

    FileUtils.mkdir_p File.dirname(dest_path) unless Dir.exists? File.dirname(dest_path)
    FileUtils.mv file.path, dest_path

    cache_file(name, dest_path)
  end

  def add_file(name, base_dir, path, file)
    raise ProjectModuleException, 'Filename is not valid.' unless is_valid_filename?(path)
    dest_path = File.join(base_dir, path)
    return if File.exists? dest_path

    FileUtils.mkdir_p File.dirname(dest_path) unless Dir.exists? File.dirname(dest_path)
    FileUtils.mv file.path, dest_path

    cache_file(name, dest_path)
  end

  def add_data_dir(dir)
    raise ProjectModuleException, 'Directory name is not valid.' unless is_valid_filename?(dir)
    dest_path = File.join(get_path(:data_files_dir), dir)
    raise ProjectModuleException, 'Directory already exists.' if File.exists? dest_path and dir != '.'

    FileUtils.mkdir_p dest_path
  end

  def remove_data_dir(dir)
    safe_delete_directory dir
    safe_create_directory dir if get_path(:data_files_dir) == dir

    # remove data files
    db.remove_files(DATA)
    # cache data files
    cache_data_files
  end

  def add_data_batch_file(file)
    begin
      success = TarHelper.untar('zxf', file, get_path(:data_files_dir))
      if success
        # remove data files
        db.remove_files(DATA)
        # cache data files
        cache_data_files
      end
      raise ProjectModuleException, 'Could not upload file. Please ensure file is a valid archive.' unless success
    rescue
      raise ProjectModuleException, 'Could not upload file. Please ensure file is a valid archive.'
    end
  end

  def is_valid_filename?(file)
    return false if file.blank?
    # TODO add regex for filename
    true
  end

  # project module settings getter and setter

  def get_settings
    JSON.parse(File.read(get_path(:settings).as_json))
  end

  def set_settings(args)
    File.open(get_path(:settings), 'w') do |file|
      file.write({:name => args[:name],
                  :key => key,
                  :version => args[:version],
                  :season => args[:season],
                  :description => args[:description],
                  :permit_no => args[:permit_no],
                  :permit_holder => args[:permit_holder],
                  :permit_issued_by => args[:permit_issued_by],
                  :permit_type => args[:permit_type],
                  :contact_address => args[:contact_address],
                  :participant => args[:participant],
                  :srid => args[:srid],
                  :copyright_holder => args[:copyright_holder],
                  :client_sponsor => args[:client_sponsor],
                  :land_owner => args[:land_owner],
                  :has_sensitive_data => args[:has_sensitive_data].nil? ? "" : args[:has_sensitive_data]}.to_json)
    end
  end

  # project module

  def create_project_module_from(tmp_dir, user = nil)
    begin
      # copy files from temp directory to project_modules directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_module_dir))

      # generate database
      Database.generate_database(get_path(:db), get_path(:data_schema), user)

      # add files to database
      cache_project_module_files

      generate_temp_files
    rescue Exception => e
      logger.error e

      FileUtils.remove_entry_secure get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory

      raise ProjectModuleException, 'Failed to create project module.'
    end
  end

  def create_project_module_from_archive_file(tmp_dir, user, upgrade = nil)
    begin
      # copy files from temp directory to project_modules directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_module_dir), ['hash_sum'])

      if upgrade
        # 1. move database to temp location
        temp_file = Tempfile.new('db')
        FileUtils.mv get_path(:db), temp_file.path
        # 2. create new database
        Database.generate_database(get_path(:db), get_path(:data_schema), user)
        # 3. migrate old database to new database
        Database.migrate_database(temp_file.path, get_path(:db))
        # 4. remove old database
        FileUtils.rm temp_file.path
      end

      # update files in database
      cache_project_module_files

      generate_temp_files
    rescue Exception => e
      logger.error e

      FileUtils.remove_entry_secure get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory

      raise ProjectModuleException, 'Failed to create module from archive.'
    end
  end

  def update_project_module_from(tmp_dir)
    begin
      # copy files from temp directory to project_modules directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_module_dir))

      # update files in database
      cache_project_module_files

      generate_database_cache
    rescue Exception => e
      logger.error e

      raise ProjectModuleException, 'Failed to update project module.'
    end
  end

  def store_database_from_android(file, user)
    begin
      # add new version
      version = db.add_version(user)

      # move file to upload directory
      stored_file = File.join(ProjectModule.uploads_path, "#{key}_v#{version}")

      FileUtils.mv(file.path, stored_file)
    rescue Exception => e
      logger.error e

      raise ProjectModuleException, 'Failed to store database from android.'
    ensure
      # TODO remove last db version?
    end
  end

  # Project archive helpers

  def cache_project_module_files
    cache_settings_files
    cache_data_files
    cache_app_files
    cache_server_files
  end

  def cache_settings_files
    # update settings files
    db.remove_old_arch16n_cache_files
    update_arch16n_cache_files
    settings_mgr.file_list.each do |file|
      cache_file(SETTINGS, File.join(settings_mgr.base_dir, file))
    end
  end

  def update_arch16n_cache_files
    settings_mgr.file_list.delete_if { |f| f.end_with? ".properties" }
    Dir.glob(get_path(:project_module_dir) + "*.properties").each {|f| @settings_mgr.add_file(f)}
  end

  def cache_data_files
    # update data files
    data_mgr.file_list.each do |file|
      cache_file(DATA, File.join(data_mgr.base_dir, file))
    end
  end

  def cache_app_files
    # update app files
    app_mgr.file_list.each do |file|
      # ignore thumbnail files
      cache_file(APP, File.join(app_mgr.base_dir, file)) unless file =~ /\.thumbnail/
    end
  end

  def cache_server_files
    # update server files
    server_mgr.file_list.each do |file|
      # ignore thumbnail files
      cache_file(SERVER, File.join(server_mgr.base_dir, file)) unless file =~ /\.thumbnail/
    end
  end

  def cache_file(name, file_path)
    return unless File.exists? file_path

    # check if file is attached to an attribute which uses thumbnails
    attached_file = file_path.to_s.gsub(get_path(:project_module_dir), '')

    thumbnail_file_path = nil
    attached_thumbnail_file = nil
    if attached_file =~ /\.original/
      thumbnail_file_path = ThumbnailCreator.create_thumbnail_for_file(file_path)
      attached_thumbnail_file = thumbnail_file_path.to_s.gsub(get_path(:project_module_dir), '')  if thumbnail_file_path
    end

    info = {
      filename: attached_file,
      md5checksum: MD5Checksum.compute_checksum(file_path),
      size: File.size(file_path),
      type: name,
      thumbnail_filename: attached_thumbnail_file,
      thumbnail_md5checksum: thumbnail_file_path ? MD5Checksum.compute_checksum(thumbnail_file_path) : nil,
      thumbnail_size: thumbnail_file_path ? File.size(thumbnail_file_path) : nil
    }
    db.insert_file(info)

    info
  end

  def generate_temp_files
    # initialise file managers
    settings_mgr.init
    db_mgr.init
    server_mgr.init
    app_mgr.init
    data_mgr.init
    package_mgr.init

    # cache current database
    generate_database_cache

    # cache current module
    archive_project_module
  end

  def generate_database_cache(version = 0)
    version ||= 0
    file = db_version_file_path(version)
    return if File.exists? file

    # need to use exclusive lock because database may be directly cloned
    db_mgr.with_exclusive_lock do
      db.create_app_database_from_version(file, version)
    end
  end

  def archive_project_module
    with_exclusive_lock do
      raise ProjectModuleException, 'Not enough space to archive module.' unless package_mgr.has_disk_space?

      success = package_mgr.update_archive(true)
      raise ProjectModuleException, 'Failed to archive module.' unless success
    end
  end

  def destroy_project_module_archive
     safe_delete_file get_path(:package_archive)
  end

  def self.validate_checksum_for_project_archive(dir)
    hash_sum = JSON.parse(File.read(File.join(dir, "hash_sum")).as_json)

    result = FileHelper.get_file_list(dir).each do |file|
      next if file == 'hash_sum'
      return false unless hash_sum[file] == MD5Checksum.compute_checksum(File.join(dir, file))
    end
    result ||= true

    result
  end

  def self.upload_project_module(file, user = nil)
    tmp_dir = Dir.mktmpdir + '/'

    logger.info "Untarring project module"
    success = TarHelper.untar('xjf', file, tmp_dir)
    raise ProjectModuleException, 'Failed to upload module.' unless success

    logger.info "Validating project module files and settings"
    module_dir = File.join(tmp_dir, Dir.entries(tmp_dir).select { |d| d != '.' and d != '..' }.first)
    settings = JSON.parse(File.read(File.join(module_dir, "module.settings")).as_json)

    if !validate_checksum_for_project_archive(module_dir)
      raise ProjectModuleException, 'Wrong hash sum for the module.'
    elsif !ProjectModule.find_by_key(settings['key']).blank?
      raise ProjectModuleException, 'This module already exists in the system.'
    elsif !ProjectModule.deleted.find_by_key(settings['key']).blank?
      raise ProjectModuleException, 'This module is deleted but already exists in the system.'
    else
      logger.info "Creating and saving project module"
      project_module = ProjectModule.new(name: settings['name'], key: settings['key'])

      begin
        project_module.save
        if File.exists? File.join(module_dir, 'version') and File.read(File.join(module_dir, 'version')).strip == Rails.application.config.faims_version
          project_module.create_project_module_from_archive_file(module_dir, user)
        else
          project_module.create_project_module_from_archive_file(module_dir, user, true)
          project_module.upgraded = true
        end
        project_module.created = true
        project_module.save
        project_module.db.associate_users
      rescue Exception => e
        logger.error e

        File.rm_rf project_module.get_path(:project_module_dir) if File.directory? project_module.get_path(:project_module_dir)
        project_module.destroy

        raise ProjectModuleException, 'Failed to upload module.'
      end

      puts "Upgraded module from Faims 1.3 to FAIMS 2.0" if project_module.upgraded
      return project_module
    end
  ensure
    FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
  end

  # Data archive helpers

  def create_data_archive(dir)
    tmp_dir = Dir.mktmpdir
    base_dir = File.join(tmp_dir, File.basename(dir))

    FileHelper.get_file_list(dir).each do |file|
      FileUtils.mkdir_p File.join(base_dir, File.dirname(file))
      FileUtils.cp File.join(dir, file), File.join(base_dir, file)
    end
    tmp_file = Tempfile.new(['data_', '.tar.gz'])

    success = TarHelper.tar('zcf', tmp_file.path, tmp_dir, File.basename(dir))
    raise ProjectModuleException, 'Failed to archive data.' unless success

    tmp_file.path
  ensure
    FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
  end

  # Export project module helpers

  def export_project_module(exporter, input, download_dir, markup_file, project_export_id)
    @project_export = ProjectModuleExport.find(project_export_id)
    input_json = File.open(File.join("/tmp", "input_" + SecureRandom.uuid + ".json"), "w+")
    input_json.write(input.to_json)
    input_json.close

    success = exporter.export(get_path(:project_module_dir), input_json.path, download_dir, markup_file)

    raise ProjectModuleException, 'Failed to export module.' unless success
  end

  # Project processor helpers

  def process_project_module(processor, action, input, download_dir, markup_file, project_process_id)
    @project_process = ProjectModuleProcess.find(project_process_id)
    input_json = File.open(File.join("/tmp","input_" + SecureRandom.uuid + ".json"),"w+")
    input_json.write(input.to_json)
    input_json.close

    success = processor.process(get_path(:project_module_dir), action, input_json.path, download_dir, markup_file)

    raise ProjectModuleException, 'Failed to run module processor.' unless success
  end

  # static

  def self.project_modules_path
    return Rails.root.to_s + '/tmp/modules' if Rails.env == 'test'
    Rails.application.config.server_project_modules_directory
  end

  def self.uploads_path
    return Rails.root.to_s + '/tmp/uploads' if Rails.env == 'test'
    Rails.application.config.server_uploads_directory
  end

  def self.upload_failures_path
    return Rails.root.to_s + '/tmp/upload_failures' if Rails.env == 'test'
    Rails.application.config.server_upload_failures_directory
  end

  # background job hooks

  def enqueue(job)
    bj = BackgroundJob.where(:delayed_job_id => job.id).first_or_create(
      :status => 'Pending',
      :project_module => self,
      :module_name => self.name,
      :delayed_job => job,
      :job_type => 'Unknown'
    )
    method_name = YAML.load(job.handler).method_name.to_s
    if method_name == 'archive_project_module'
      bj.job_type = 'Archive Module'
    elsif method_name == 'export_project_module'
      args = YAML.load(job.handler).args
      project_export = ProjectModuleExport.where(:project_module_id => self, :exporter => args[0].key, :options => args[1].to_json).first
      if !project_export.blank?
        project_export.background_job = bj
        project_export.save
      end
      bj.job_type = 'Export Module'
    elsif method_name == 'process_project_module'
      args = YAML.load(job.handler).args
      project_process = ProjectModuleProcess.where(:project_module_id => self, :processor => args[0].key, :options => args[2].to_json).first
      if !project_process.blank?
        project_process.background_job = bj
        project_process.save
      end
      bj.job_type = 'Process Module'

    end
    bj.save
  end

  def before(job)
    bj = BackgroundJob.where(:delayed_job_id => job.id).last
    bj.status = 'Running'
    bj.save
  end

  def after(job)
    bj = BackgroundJob.where(:delayed_job_id => job.id).last
    bj.status = 'Finished'
    bj.save
  end

  def success(job)
    bj = BackgroundJob.where(:delayed_job_id => job.id).last
    bj.status = 'Finished Successfully'
    bj.save
  end

  def error(job, exception)
    bj = BackgroundJob.where(:delayed_job_id => job.id).last
    bj.status = 'Failed'
    bj.failure_message = exception.message
    bj.save
  end

  def failure(job)
    bj = BackgroundJob.where(:delayed_job_id => job.id).last
    bj.status = 'Failed'
    bj.failure_message = job.last_error
    bj.save
  end

  # instance-less version

  ModuleUploadJob = Struct.new(:file, :tmpfile, :current_user) do
    def enqueue(job)
      bj = BackgroundJob.where(:delayed_job_id => job.id).first_or_create(
        :status => 'Pending',
        :project_module => nil,
        #:user => current_user,
        :job_type => "Upload Module",
        :module_name => file,
        :delayed_job => job
      )
      #bj.save
    end

    def perform
      Rails.logger.warn file.inspect
      ProjectModule.upload_project_module(tmpfile, current_user)
    end

    def before(job)
      bj = BackgroundJob.where(:delayed_job_id => job.id).last
      bj.status = 'Running'
      bj.save
    end

    def after(job)
      bj = BackgroundJob.where(:delayed_job_id => job.id).last
      bj.status = 'Finished'
      bj.save
    end

    def success(job)
      bj = BackgroundJob.where(:delayed_job_id => job.id).last
      bj.status = 'Finished Successfully'
      bj.save
    end

    def error(job, exception)
      bj = BackgroundJob.where(:delayed_job_id => job.id).last
      bj.status = 'Failed'
      bj.failure_message = exception.message
      bj.save
    end

    def failure(job)
      bj = BackgroundJob.where(:delayed_job_id => job.id).last
      bj.status = 'Failed'
      bj.failure_message = job.last_error
      bj.save
    end
  end
end
