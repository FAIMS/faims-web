# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :user_module do
    user nil
    project_module nil
    password "MyText"
  end
end
