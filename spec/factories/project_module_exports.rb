# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_module_export do
    project_module nil
    project_exporter nil
    background_job nil
    uuid "MyText"
  end
end
