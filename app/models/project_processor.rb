class ProjectProcessor
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  class ProjectProcessorException < Exception
  end

  CONFIG_FILE = 'config.json'
  INSTALL_SCRIPT = 'install.sh'
  UNINSTALL_SCRIPT = 'uninstall.sh'
  #PROCESS_SCRIPT = 'process.sh'

  # validations
  validates :dir, presence: true
  validate :validate_config
  validate :validate_install_script
  validate :validate_uninstall_script
  #validate :validate_process_script

  def validate_config
    return errors.add(:config, 'Cannot find config') unless File.exists? get_path(:config)

    config_json = get_config_json

    errors.add(:config, 'Config is missing processor key') if config_json['key'].blank?
    errors.add(:config, 'Config is missing processor name') if config_json['name'].blank?
    errors.add(:config, 'Config is missing processor version') if config_json['version'].blank?
  end

  def validate_install_script
    return errors.add(:install_script, 'Cannot find install script') unless File.exists? get_path(:install_script)
  end

  def validate_uninstall_script
    return errors.add(:uninstall_script, 'Cannot find uninstall script') unless File.exists? get_path(:uninstall_script)
  end

  # def validate_process_script
  #   return errors.add(:process_script, 'Cannot find process script') unless File.exists? get_path(:process_script)
  # end

  def initialize(dir = nil)
    @dir = dir
  end

  def dir
    @dir
  end

  def key
    config_json = get_config_json
    return config_json['key'] if config_json
  end

  def name
    config_json = get_config_json
    return config_json['name'] if config_json
  end

  def version
    config_json = get_config_json
    return config_json['version'] if config_json
  end

  def can_update?
    Dir.exists? File.join(dir, '.git')
  end

  def get_config_json
    JSON.parse(get_raw_config)
  rescue JSON::ParserError
    raise ProjectProcessorException, 'Cannot parse config as json'
  end

  def get_raw_config
    File.open(get_path(:config), 'r').read
  end

  def get_path(type, action=nil)
    return File.join(@dir, CONFIG_FILE) if type == :config
    return File.join(@dir, INSTALL_SCRIPT) if type == :install_script
    return File.join(@dir, UNINSTALL_SCRIPT) if type == :uninstall_script
    #return File.join(@dir, PROCESS_SCRIPT) if type == :process_script
    if type == :process_script && !action.blank?
      config = get_config_json
      script = config['actions'].find{|a| a['id'] == action}["script"]
      return File.join(@dir, script) if script
    end
  end

  def install
    # check if install script exists
    raise ProjectProcessorException, "Processor doesn't contain install.sh script" unless File.exists? get_path(:install_script)

    # check if processor already exists then version is greater
    processor = ProjectProcessor.find_by_key(key)
    raise ProjectProcessorException, "Processor '#{processor.name}' already exists with version '#{processor.version}'" if processor and version <= processor.version

    # delete old processor
    processor.uninstall if processor

    # move the processor into the processors_dir
    Dir.mkdir ProjectProcessor.processors_dir unless Dir.exists? ProjectProcessor.processors_dir
    FileUtils.mv dir, ProjectProcessor.processors_dir
    @dir = File.join(ProjectProcessor.processors_dir, File.basename(dir))

    # run the install script
    result = execute_script(File.basename(get_path(:install_script)))
    FileUtils.rm_rf @dir unless result

    result
  end

  def uninstall
    # check if uninstall script exists
    raise ProjectProcessorException, "Processor doesn't contain uninstall.sh script" unless File.exists? get_path(:uninstall_script)

    # run the uninstall script
    result = execute_script(File.basename(get_path(:uninstall_script)))

    # delete the processor from the processors_dir
    FileUtils.rm_rf dir if result and Dir.exists? dir

    result
  end

  def update
    return unless can_update?

    # update processor
    execute_command("cd #{dir} && git pull")

    # re-run installer
    execute_script(File.basename(get_path(:install_script)))
  end

  def process(module_dir, action, input_json, download_dir, markup_file)
    # check if process action script exists
    raise ProjectProcessorException, "Processor doesn't contain script for #{action}" unless File.exists? get_path(:process_script, action)

    params = [module_dir, input_json, download_dir, markup_file].join(" ")

    # run the process script
    execute_script(File.basename(get_path(:process_script, action)), params)
  end

  def parse_action_interface_inputs(action,input)
    attributes = {}
    config = get_config_json
    if config and input and action
      if config['actions']
        config_action = config['actions'].find{|a| a['id'] == action}
        if config_action['interface']
          config_action['interface'].each do |field|
            if field['type'] == 'checkbox'
              values = []
              if field['items']
                field['items'].each do |item|
                  checked = input["#{field['label']}:#{item}"]
                  values << item if checked == "true"
                end
              end
              attributes[field['label']] = values
            elsif field['type'] == 'upload'
              if input[field['label']].class == Array
                files = []
                for elem in input[field['label']]
                  files << { filename: elem.original_filename, tempfile: elem.tempfile.path }
                end
                attributes[field['label']] = files
              else
                attributes[field['label']] = {input[field['label']].original_filename => input[field['label']].tempfile.path}
              end
            else
              attributes[field['label']] = input[field['label']]
            end
          end
        end
      end
    end
    attributes
  end

  class << self

    def all
      return [] unless processors_dir and Dir.exists? processors_dir

      dirs = Dir["#{processors_dir}/*"]
      processors = dirs.select do |dir|
        processor = ProjectProcessor.new(dir)
        processor.valid?
      end.map { |dir| ProjectProcessor.new(dir) }

      processors
    end

    def find_by_name(name)
      all.select{ |processor| processor.name == name }.first
    end

    def find_by_key(key)
      all.select{ |processor| processor.key == key }.first
    end

    def extract_processor(processor_tarball)
      # extract tarball
      tmp_dir = Dir.mktmpdir
      process_dir = Dir.mktmpdir
      raise ProjectProcessorException, 'Cannot extract archive' unless TarHelper.untar('xzf', processor_tarball, tmp_dir)

      # validate tarball
      base_dir = Dir["#{tmp_dir}/*"].first
      raise ProjectProcessorException, 'Cannot find directory in archive' unless base_dir and Dir.exists? base_dir

      # move contents to process directory
      entries = Dir.entries(base_dir).select { |d| d != '.' and d != '..' }.map { |d| File.join(base_dir, d) }
      FileUtils.cp_r entries, process_dir

      process_dir
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and Dir.exists? tmp_dir
    end

    def processors_dir
      Rails.env == 'test' ? Rails.root.join('tmp/processors') : Rails.application.config.processors_dir
    end

    def processor_log
      Rails.root.join('log/processors.log').to_s
    end

  end

  private

  def execute_script(script, params = nil)
    unless Rails.env.test?
      system("cd #{dir} && sudo bash #{script} #{params.to_s} >> #{ProjectProcessor.processor_log} 2>&1")
    else
      system("cd #{dir} && bash #{script} #{params.to_s} >> #{ProjectProcessor.processor_log} 2>&1")
    end
  end

  def execute_command(command)
    system("#{command} >> #{ProjectProcessor.processor_log} 2>&1")
  end

end
