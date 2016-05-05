require 'spec_helper'

describe BackgroundJob do
	describe "Assocations" do
		it { should belong_to(:project_module) }
		it { should belong_to(:project_exporter) }
		it { should belong_to(:delayed_job) }
		it { should belong_to(:user) }
	end

	describe "Scopes" do
		describe "By updated date" do
			it "should order background jobs by updated date" do
				bj1 = BackgroundJob.create(job_type: "Test Job", module_name: "Fake module 1", status: "Pending")
				bj2 = BackgroundJob.create(job_type: "Test Job", module_name: "Fake module 1", status: "Pending")
				bj3 = BackgroundJob.create(job_type: "Test Job", module_name: "Fake module 1", status: "Pending")

				BackgroundJob.all.should eq([bj3, bj2, bj1])
			end
		end
	end

	describe "Validations" do
		it { should validate_presence_of(:job_type) }
		it { should validate_presence_of(:module_name) }
		it { should validate_presence_of(:status) }
	end
end
