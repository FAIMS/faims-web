# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_module do
    user nil
    project_module nil
    password "MyText"
  end
end
