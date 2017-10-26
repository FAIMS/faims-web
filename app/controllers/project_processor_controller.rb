class ProjectProcessorController < ApplicationController
  include ProjectProcessorBreadCrumbs
  before_filter :crumbs
  before_filter :authenticate_user!
  load_and_authorize_resource :project_processor

  def index
    page_crumbs :pages_home, :processors_index
    @project_processors = ProjectProcessor.all
  end

  def new
    page_crumbs :pages_home, :processors_index, :processors_add
    @project_processor = ProjectProcessor.new
  end

  def create
    unless params[:project_processor] and params[:project_processor][:tarball]
      flash.now[:error] = 'Please choose a processor to export.'
      return render 'new'
    end
    tarball = params[:project_processor][:tarball]

    begin
      dir = ProjectProcessor.extract_processor(tarball.tempfile.path)
      @project_processor = ProjectProcessor.new(dir)
      if @project_processor.valid?
        if @project_processor.install
          flash[:notice] = 'Processor installed.'
          return redirect_to project_processors_path
        else
          flash.now[:error] = 'Processor failed to install. Please correct the errors in the install script.'
        end
      else
        flash.now[:error] = 'Please correct the errors in the processor.'
      end
      render 'new'
    rescue ProjectProcessor::ProjectProcessorException => e
      logger.error e
      flash.now[:error] = e.message
      return render 'new'
    end
  end

  def delete
    @project_processor = ProjectProcessor.find_by_key(params[:key])
    unless @project_processor
      flash[:error] = 'Processor does not exist.'
      return redirect_to project_processors_path
    end

    begin
      result = @project_processor.uninstall
      if result
        flash[:notice] = 'Processor uninstalled.'
      else
        flash[:error] = 'Processor failed to uninstall. Please correct the errors in the uninstall script.'
      end
    rescue ProjectProcessor::ProjectProcessorException => e
      logger.error e
      flash[:error] = e.message
    end
    redirect_to project_processors_path
  end

  def update
    @project_processor = ProjectProcessor.find_by_key(params[:key])
    unless @project_processor
      flash[:error] = 'Processor does not exist.'
      return redirect_to project_processors_path
    end

    begin
      result = @project_processor.update
      if result
        flash[:notice] = 'Processor updated.'
      else
        flash[:error] = 'Processor failed to update.'
      end
    rescue ProjectProcessor::ProjectProcessorException => e
      logger.error e
      flash[:error] = e.message
    end
    redirect_to project_processors_path
  end

end
