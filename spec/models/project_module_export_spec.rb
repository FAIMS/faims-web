require 'spec_helper'

describe ProjectModuleExport do
	describe "Assocations" do
		it { should belong_to(:project_module) }
		it { should belong_to(:background_job) }
	end
end
