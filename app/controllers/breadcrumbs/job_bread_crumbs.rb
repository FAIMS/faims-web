module JobBreadCrumbs

  def crumbs
    @crumbs =
        {
            :pages_home => {title: 'Home', url: pages_home_path},
            :jobs_index => {title: 'Background Jobs', url: jobs_path},
        }
  end

  def page_crumbs(*value)
    @page_crumbs = value
  end

end