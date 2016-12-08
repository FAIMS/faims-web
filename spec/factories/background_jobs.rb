# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :background_job do
    status "MyString"
    project_module nil
    project_exporter nil
    job_type "MyString"
    user nil
    module_name "MyString"
  end
end
