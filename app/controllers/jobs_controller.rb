class JobsController < ApplicationController
  include JobBreadCrumbs
  before_filter :crumbs
  before_filter :authenticate_user!

  def index
    page_crumbs :pages_home, :jobs_index
    @jobs = BackgroundJob.limit(25)
  end
end
