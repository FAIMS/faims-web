module ProjectProcessorBreadCrumbs

  def crumbs
    @crumbs =
        {
            :pages_home => {title: 'Home', url: pages_home_path},

            :processors_index => {title: 'Processors', url: project_processors_path},
            :processors_add => {title: 'Add', url: new_project_processor_path}
        }
  end

  def page_crumbs(*value)
    @page_crumbs = value
  end

end
