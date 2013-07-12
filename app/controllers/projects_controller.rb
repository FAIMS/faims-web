require Rails.root.join('app/models/projects/database')

class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  def index

  end

  def new
    @project = Project.new
    @spatial_list = Database.get_spatial_ref_list

    # make temp directory and store its path in session
    create_tmp_dir
  end

  def create
    # create project if valid and schemas uploaded

    valid = create_project

    if valid

      @project.transaction do
        @project.save

        @project.update_settings(params)
        @project.create_project_from(session[:tmpdir])

        FileUtils.remove_entry_secure session[:tmpdir]
      end

      flash[:notice] = t 'projects.new.success'
      redirect_to :projects
    else
      @spatial_list = Database.get_spatial_ref_list
      flash.now[:error] = t 'projects.new.failure'
      render 'new'
    end
  end

  def show
    @project = Project.find(params[:id])
    session[:has_attached_files] = @project.has_attached_files
  end

  def edit_project_user
    @project = Project.find(params[:id])
    @users = @project.db.get_list_of_users
    @server_user = User.where('id NOT IN (?)', @users.transpose[0])
  end

  def update_project_user
    @project = Project.find(params[:id])
    user = User.find(params[:user_id])
    @project.db.update_list_of_users(user)
    @users = @project.db.get_list_of_users
    @server_user = User.where('id NOT IN (?)', @users.transpose[0])
    flash[:notice] = 'Successfully updated user'
    render 'edit_project_user'
  end

  # Arch entity functionalities

  def list_arch_ent_records
    @project = Project.find(params[:id])
    @type = @project.db.get_arch_ent_types
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
  end

  def list_typed_arch_ent_records
    @project = Project.find(params[:id])
    limit = 25
    type = params[:type]
    offset = params[:offset]
    session[:type] = type
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    session[:action] = 'list_typed_arch_ent_records'
    @uuid = @project.db.load_arch_entity(type,limit,offset)

    @entity_dirty_map = {}
    @uuid.each do |row|
      @entity_dirty_map[row[0]] = @project.db.is_arch_entity_dirty(row[0]) unless @entity_dirty_map[row[0]]
    end

  end

  def search_arch_ent_records
    @project = Project.find(params[:id])
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
  end

  def show_arch_ent_records
    @project = Project.find(params[:id])
    limit = 25
    query = params[:query]
    offset = params[:offset]
    session[:query] = query
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    session[:action] = 'show_arch_ent_records'
    @uuid = @project.db.search_arch_entity(limit,offset,query)

    @entity_dirty_map = {}
    @uuid.each do |row|
      @entity_dirty_map[row[0]] = @project.db.is_arch_entity_dirty(row[0]) unless @entity_dirty_map[row[0]]
    end
  end

  def edit_arch_ent_records
    @project = Project.find(params[:id])
    uuid = params[:uuid]
    session[:uuid] = uuid
    @attributes = @project.db.get_arch_entity_attributes(uuid)
    @vocab_name = {}
    for attribute in @attributes
      @vocab_name[attribute[1]] = @project.db.get_vocab(attribute[1])
    end
  end

  def update_arch_ent_records
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    else
      uuid = params[:uuid]
      vocab_id = !params[:attr][:vocab_id].blank? ? params[:attr][:vocab_id] : nil
      attribute_id = !params[:attr][:attribute_id].blank? ? params[:attr][:attribute_id] : nil
      measure = !params[:attr][:measure].blank? ? params[:attr][:measure] : nil
      freetext = !params[:attr][:freetext].blank? ? params[:attr][:freetext] : nil
      certainty = !params[:attr][:certainty].blank? ? params[:attr][:certainty] : nil

      ignore_errors = !params[:attr][:ignore_errors].blank? ? params[:attr][:ignore_errors] : nil

      @project.db.update_arch_entity_attribute(uuid,current_user.id,vocab_id,attribute_id, measure, freetext, certainty, ignore_errors)

      @attributes = @project.db.get_arch_entity_attributes(uuid)
      @vocab_name = {}
      for attribute in @attributes
        @vocab_name[attribute[1]] = @project.db.get_vocab(attribute[1])
      end
      render 'edit_arch_ent_records'
    end

  end

  def delete_arch_ent_records
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end

    uuid = params[:uuid]
    @project.db.delete_arch_entity(uuid,current_user.id)

    if session[:type]
      redirect_to(list_typed_arch_ent_records_path(@project) + '?type=' + session[:type] + '&offset=0')
    else
      redirect_to(show_arch_ent_records_path(@project) + '?query=' + session[:query] + '&offset=0')
    end

  end

  def compare_arch_ents
    @project = Project.find(params[:id])
    session[:values] = []
    session[:identifiers] = []
    session[:timestamps] = []
    ids = params[:ids]
    @identifiers = params[:identifiers]
    @timestamps = params[:timestamps]
    @first_uuid = ids[0]
    @second_uuid = ids[1]
  end

  def merge_arch_ents
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end
    @project.db.delete_arch_entity(params[:deleted_id],current_user.id)

    @project.db.insert_updated_arch_entity(params[:uuid],current_user.id, params[:vocab_id],params[:attribute_id], params[:measure], params[:freetext], params[:certainty])
    if session[:type]
      redirect_to(list_typed_arch_ent_records_path(@project) + '?type=' + session[:type] + '&offset=0')
      return
    else
      redirect_to(show_arch_ent_records_path(@project) + '?query=' + session[:query] + '&offset=0')
      return
    end
  end

  def show_arch_ent_history
    @project = Project.find(params[:id])
    uuid = params[:uuid]
    @timestamps = @project.db.get_arch_ent_history(uuid)
  end

  def revert_arch_ent_to_timestamp
    @project = Project.find(params[:id])
    uuid = params[:uuid]
    timestamp = params[:timestamp]
    @project.db.revert_arch_ent_to_timestamp(uuid,current_user.id, timestamp)
    redirect_to edit_arch_ent_records_path(@project, uuid)
  end

  # Relationship functionalities

  def list_rel_records
    @project = Project.find(params[:id])
    @type = @project.db.get_rel_types
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
  end

  def list_typed_rel_records
    @project = Project.find(params[:id])
    limit = 25
    type=params[:type]
    offset = params[:offset]
    session[:type] = type
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    session[:action] = 'list_typed_rel_records'
    @relationshipid = @project.db.load_rel(type,limit,offset)

    @rel_dirty_map = {}
    @relationshipid.each do |row|
      @rel_dirty_map[row[0]] = @project.db.is_relationship_dirty(row[0]) unless @rel_dirty_map[row[0]]
    end
  end

  def search_rel_records
    @project = Project.find(params[:id])
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
  end

  def show_rel_records
    @project = Project.find(params[:id])
    limit = 25
    query = params[:query]
    offset = params[:offset]
    relationshipid = params[:relationshipid]
    session[:relationshipid] = relationshipid
    session[:query] = query
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    session[:action] = 'show_rel_records'
    @relationshipid = @project.db.search_rel(limit,offset,query)

    @rel_dirty_map = {}
    @relationshipid.each do |row|
      @rel_dirty_map[row[0]] = @project.db.is_relationship_dirty(row[0]) unless @rel_dirty_map[row[0]]
    end
  end

  def edit_rel_records
    @project = Project.find(params[:id])
    relationshipid = params[:relationshipid]
    session[:relationshipid] = relationshipid
    @attributes = @project.db.get_rel_attributes(relationshipid)
    @vocab_name = {}
    for attribute in @attributes
      @vocab_name[attribute[2]] = @project.db.get_vocab(attribute[2])
    end
  end

  def update_rel_records
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    else
      relationshipid = params[:relationshipid]
      vocab_id = !params[:attr][:vocab_id].blank? ? params[:attr][:vocab_id] : nil
      attribute_id = !params[:attr][:attribute_id].blank? ? params[:attr][:attribute_id] : nil
      freetext = !params[:attr][:freetext].blank? ? params[:attr][:freetext] : nil
      certainty = !params[:attr][:certainty].blank? ? params[:attr][:certainty] : nil

      ignore_errors = !params[:attr][:ignore_errors].blank? ? params[:attr][:ignore_errors] : nil

      @project.db.update_rel_attribute(relationshipid,current_user.id,vocab_id,attribute_id, freetext, certainty, ignore_errors)

      @attributes = @project.db.get_rel_attributes(relationshipid)
      @vocab_name = {}
      for attribute in @attributes
        @vocab_name[attribute[2]] = @project.db.get_vocab(attribute[2])
      end
      render 'edit_rel_records'
    end

  end

  def show_rel_history
    @project = Project.find(params[:id])
    relid = params[:relid]
    @timestamps = @project.db.get_rel_history(relid)
  end

  def revert_rel_to_timestamp
    @project = Project.find(params[:id])
    relid = params[:relid]
    timestamp = params[:timestamp]
    @project.db.revert_rel_to_timestamp(relid,current_user.id, timestamp)
    redirect_to edit_rel_records_path(@project, relid)
  end

  def delete_rel_records
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end

    relationshipid = params[:relationshipid]
    @project.db.delete_relationship(relationshipid,current_user.id)
    if session[:type]
      redirect_to(list_typed_rel_records_path(@project) + '?type=' + session[:type] + '&offset=0')
    else
      redirect_to(show_rel_records_path(@project) + '?query=' + session[:query] + '&offset=0')
    end
  end

  def show_rel_members
    @project = Project.find(params[:id])
    session[:relationshipid] = params[:relationshipid]
    limit = 25
    offset = params[:offset]
    session[:relntypeid] = params[:relntypeid]
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    session[:show] = 'show_rel_members'
    @uuid = @project.db.get_rel_arch_ent_members(params[:relationshipid], limit, offset)
  end

  def remove_arch_ent_member
    @project = Project.find(params[:id])
    relationshipid = params[:relationshipid]
    uuid = params[:uuid]
    @project.db.delete_arch_ent_member(relationshipid,current_user.id,uuid)
    render :nothing => true
  end

  def search_arch_ent_member
    @project = Project.find(params[:id])
    session[:relationshipid] = params[:relationshipid]
    session[:relntypeid] = params[:relntypeid]
    if params[:search_query].nil?
      @uuid = nil
      @status = 'init'
      session.delete(:search_query)
    else
      limit = 25
      offset = params[:offset]
      session[:search_query] = params[:search_query]
      session[:cur_offset] = offset
      session[:prev_offset] = Integer(offset) - Integer(limit)
      session[:next_offset] = Integer(offset) + Integer(limit)
      @uuid = @project.db.get_non_member_arch_ent(params[:relationshipid],params[:search_query],limit,offset)
    end
    @verb = @project.db.get_verbs_for_relation(params[:relntypeid])
  end

  def add_arch_ent_member
    @project = Project.find(params[:id])
    @project.db.add_arch_ent_member(params[:relationshipid],current_user.id,params[:uuid],params[:verb])
    respond_to do |format|
      format.json { render :json => {:result => 'success', :url => show_rel_members_path(@project,params[:relationshipid])+'?offset=0&relntypeid='+params[:relntypeid]} }
    end
  end

  def add_entity_to_compare
    if !session[:values]
      session[:values] = []
    end
    if !session[:values].include?(params[:value])
      session[:values].push(params[:value])
    end
    if !session[:identifiers]
      session[:identifiers] = []
    end
    if !session[:identifiers].include?(params[:identifier])
      session[:identifiers].push(params[:identifier])
    end
    if !session[:timestamps]
      session[:timestamps] = []
    end
    if !session[:timestamps].include?(params[:timestamp])
      session[:timestamps].push(params[:timestamp])
    end

    render :nothing => true
  end

  def remove_entity_to_compare
    if(session[:values])
      session[:values].delete(params[:value])
    end
    if !session[:identifiers]
      session[:identifiers].delete(params[:identifier])
    end
    if !session[:timestamps]
      session[:timestamps].delete(params[:timestamp])
    end
    render :nothing => true
  end

  def compare_rel
    @project = Project.find(params[:id])
    ids = params[:ids]
    session[:values] = []
    session[:identifiers] = []
    session[:timestamps] = []
    @identifiers = params[:identifiers]
    @timestamps = params[:timestamps]
    @first_rel_id = ids[0]
    @second_rel_id = ids[1]
  end

  def merge_rel
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end
    @project.db.delete_relationship(params[:deleted_id],current_user.id)

    @project.db.insert_updated_rel(params[:rel_id],current_user.id, params[:vocab_id], params[:attribute_id],  params[:freetext], params[:certainty])
    if session[:type]
      redirect_to(list_typed_rel_records_path(@project) + '?type=' + session[:type] + '&offset=0')
      return
    else
      redirect_to(show_rel_records_path(@project) + '?query=' + session[:query] + '&offset=0')
      return
    end
  end

  def list_attributes_with_vocab
    @project = Project.find(params[:id])
    @attributes = @project.db.get_attributes_containing_vocab()
  end

  def list_vocab_for_attribute
    @project = Project.find(params[:id])
    attribute_id = params[:attribute_id]
    vocabs = @project.db.get_vocabs_for_attribute(attribute_id)
    vocabularies = []
    vocabs.each do |vocab|
      vocabulary = {}
      vocabulary['vocab_id'] = vocab[1]
      vocabulary['vocab_name'] = vocab[2]
      vocabularies.push(vocabulary)
    end
    respond_to do |format|
      format.json { render :json => vocabularies.to_json }
    end
  end

  def update_attributes_vocab
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end
    vocab_id = params[:vocab_id]
    vocab_name = params[:vocab_name]
    @attribute_id = params[:attribute_id]
    @project.db.update_attributes_vocab(@attribute_id, vocab_id, vocab_name)
    @attributes = @project.db.get_attributes_containing_vocab()
    flash[:notice] = 'Successfully updated vocabulary'
    render 'list_attributes_with_vocab'
  end

  def edit_project
    @project = Project.find(params[:id])
    project_setting = JSON.parse(File.read(@project.get_path(:settings)))
    session[:name] = @project.name
    session[:season] = project_setting['season']
    session[:description] = project_setting['description']
    session[:permit_no] = project_setting['permit_no']
    session[:permit_holder] = project_setting['permit_holder']
    session[:contact_address] = project_setting['contact_address']
    session[:participant] = project_setting['participant']
    session[:srid] = project_setting['srid']
    create_tmp_dir
    @spatial_list = Database.get_spatial_ref_list
  end

  def update_project
    if @project.settings_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end
    valid = validate_project_update
    if valid
      if @project.update_attributes(:name => params[:project][:name])
        @project.update_settings(params)

        @project.update_project_from(session[:tmpdir])

        FileUtils.remove_entry_secure session[:tmpdir]

        flash[:notice] = 'Successfully updated project'
        redirect_to :project
        return
      else
        session[:name] = params[:project][:name]
        session[:season] = params[:project][:season]
        session[:description] = params[:project][:description]
        session[:permit_no] = params[:project][:permit_no]
        session[:permit_holder] = params[:project][:permit_holder]
        session[:contact_address] = params[:project][:contact_address]
        session[:participant] = params[:project][:participant]
        session[:srid] = params[:project][:srid]
        @spatial_list = Database.get_spatial_ref_list
        flash.now[:error] = 'Error updating project'
        render 'edit_project'
        return
      end
    else
      session[:name] = params[:project][:name]
      session[:season] = params[:project][:season]
      session[:description] = params[:project][:description]
      session[:permit_no] = params[:project][:permit_no]
      session[:permit_holder] = params[:project][:permit_holder]
      session[:contact_address] = params[:project][:contact_address]
      session[:participant] = params[:project][:participant]
      session[:srid] = params[:project][:srid]
      @spatial_list = Database.get_spatial_ref_list
      flash.now[:error] = 'Error updating project'
      render 'edit_project'
      return
    end
  end

  def download_attached_file
    send_file Rails.root.join("projects/#{Project.find(params[:id]).key}/#{params[:path]}"), :filename => params[:name]
  end

  def update

  end

  def archive_project
    @project = Project.find(params[:id])
    if !@project.package_mgr.locked?
      begin
        job = @project.delay.package_project
        session[:job] = job.id
      rescue Exception => e
        raise e
      end
    end
    respond_to do |format|
      format.json { render :json => {:archive => 'false'} } if @project.package_mgr.locked?
      format.json { render :json => {:archive => 'true'} } if !@project.package_mgr.locked?
    end
  end

  def check_archive_status
    @project = Project.find(params[:id])
    jobid = session[:job]
    if !Delayed::Job.exists?(jobid)
      session[:job] = nil
    end
    respond_to do |format|
      format.json { render :json => {:finish => 'false'} } if Delayed::Job.exists?(jobid)
      format.json { render :json => {:finish => 'true'} } if !Delayed::Job.exists?(jobid)
    end
  end

  def download_project
    @project = Project.find(params[:id])
    if @project.package_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
    end

    @project.package_mgr.with_lock do
      send_file @project.get_path(:package_archive), :type => 'application/bzip2', :x_sendfile => true, :stream => false
    end
  end

  def upload_project
    @project = Project.new
  end

  def upload_new_project
    if params[:project]
      project_or_error = Project.upload_project(params)
      if project_or_error.class == String
        @project = Project.new
        flash.now[:error] = project_or_error
        render 'upload_project'
      else
        @project = project_or_error
        flash[:notice] = 'Project has been successfully uploaded'
        redirect_to :projects
      end
    else
      @project = Project.new
      flash.now[:error] = 'Please upload an archive of the project'
      render 'upload_project'
    end
  end
  private

  def create_tmp_dir
    clear_tmp_dir
    tmpdir = Dir.mktmpdir
    session[:tmpdir] = tmpdir
    session[:data_schema] = false
    session[:ui_schema] = false
    session[:ui_logic] = false
    session[:arch16n] = false
    session[:validation_schema] = false
  end

  def clear_tmp_dir
    FileUtils.remove_entry_secure session[:tmpdir] if !session[:tmpdir].blank? and File.directory? session[:tmpdir]
    session[:tmpdir] = nil
  end

  def create_project
    # check if project is valid

    valid = false
    if params[:project]
      @project = Project.new(:name => params[:project][:name], :key => SecureRandom.uuid) if params[:project]
      valid = @project.valid?
    end

    # check if data schema is valid
    if !session[:data_schema]
      error = Project.validate_data_schema(params[:project][:data_schema])
      if error
        @project.errors.add(:data_schema, error)
        valid = false
      else
        create_temp_file(@project.get_name(:data_schema), params[:project][:data_schema])
        session[:data_schema] = true
      end
    end

    # check if ui schema is valid
    if !session[:ui_schema]
      error = Project.validate_ui_schema(params[:project][:ui_schema])
      if error
        @project.errors.add(:ui_schema, error)
        valid = false
      else
        create_temp_file(@project.get_name(:ui_schema), params[:project][:ui_schema])
        session[:ui_schema] = true
      end
    end

    # check if ui logic is valid
    if !session[:ui_logic]
      error = Project.validate_ui_logic(params[:project][:ui_logic])
      if error
        @project.errors.add(:ui_logic, error)
        valid = false
      else
        create_temp_file(@project.get_name(:ui_logic), params[:project][:ui_logic])
        session[:ui_logic] = true
      end
    end

    # check if arch16n is valid
    if !session[:arch16n]
      error = Project.validate_arch16n(params[:project][:arch16n],params[:project][:name])
      if error
        @project.errors.add(:arch16n, error)
        valid = false
      else
        if !params[:project][:arch16n].nil?
          create_temp_file(@project.get_name(:project_properties), params[:project][:arch16n])
          session[:arch16n] = true
        end
      end
    end

    # check if validation schema is valid
    if !session[:validation_schema]
      error = Project.validate_validation_schema(params[:project][:validation_schema])
      if error
        @project.errors.add(:validation_schema, error)
        valid = false
      else
        if !params[:project][:validation_schema].nil?
          create_temp_file(@project.get_name(:validation_schema), params[:project][:validation_schema])
          session[:validation_schema] = true
        end
      end
    end

    if valid
      session[:season] = ''
      session[:description] = ''
      session[:permit_no] = ''
      session[:permit_holder] = ''
      session[:contact_address] = ''
      session[:participant] = ''
      session[:srid] = ''
    else
      session[:season] = params[:project][:season]
      session[:description] = params[:project][:description]
      session[:permit_no] = params[:project][:permit_no]
      session[:permit_holder] = params[:project][:permit_holder]
      session[:contact_address] = params[:project][:contact_address]
      session[:participant] = params[:project][:participant]
      session[:srid] = params[:project][:srid]
    end

    valid
  end

  def validate_project_update
    # check if project is valid

    valid = true

    # check if ui schema is valid
    if !session[:ui_schema]
      if !params[:project][:ui_schema].blank?
        error = Project.validate_ui_schema(params[:project][:ui_schema])
        if error
          @project.errors.add(:ui_schema, error)
          valid = false
        else
          create_temp_file(@project.get_name(:ui_schema), params[:project][:ui_schema])
          session[:ui_schema] = true
        end
      end
    end

    # check if arch16n is valid
    if !session[:ui_logic]
      if !params[:project][:ui_logic].nil?
        create_temp_file(@project.get_name(:ui_logic), params[:project][:ui_logic])
        session[:ui_logic] = true
      end
    end

    # check if arch16n is valid
    if !session[:arch16n]
      error = Project.validate_arch16n(params[:project][:arch16n],params[:project][:name])
      if error
        @project.errors.add(:arch16n, error)
        valid = false
      else
        if !params[:project][:arch16n].nil?
          create_temp_file(@project.get_name(:project_properties), params[:project][:arch16n])
          session[:arch16n] = true
        end
      end
    end

    # check if validation schema is valid
    if !session[:validation_schema]
      error = Project.validate_validation_schema(params[:project][:validation_schema])
      if error
        @project.errors.add(:validation_schema, error)
        valid = false
      else
        if !params[:project][:validation_schema].nil?
          create_temp_file(@project.get_name(:validation_schema), params[:project][:validation_schema])
          session[:validation_schema] = true
        end
      end
    end

    if valid
      session[:season] = ''
      session[:description] = ''
      session[:permit_no] = ''
      session[:permit_holder] = ''
      session[:contact_address] = ''
      session[:participant] = ''
      session[:srid] = ''
    else
      session[:season] = params[:project][:season]
      session[:description] = params[:project][:description]
      session[:permit_no] = params[:project][:permit_no]
      session[:permit_holder] = params[:project][:permit_holder]
      session[:contact_address] = params[:project][:contact_address]
      session[:participant] = params[:project][:participant]
      session[:srid] = params[:project][:srid]
    end

    valid
  end

  def create_temp_file(filename, upload)
    tmpdir = session[:tmpdir]
    File.open(upload.tempfile, 'r') do |upload_file|
      File.open(tmpdir + '/' + filename, 'w') do |temp_file|
        temp_file.write(upload_file.read)
      end
    end
  end

end
