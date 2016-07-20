WAIT_RANGE = (1..5)

require File.expand_path("../../../spec/tools/helpers/database_generator_spec_helper", __FILE__)

# Given a step like 'I search for record "1" belonging to this Robotium test'
# We will search for e.g. "132_1446_ua" then click on "132_1446_ua's save count:1."
# 
Then(/^I search for record "([^"]*)" belonging to this Robotium test$/) do |record|
  page.fill_in 'query', :with => ENV['ROBOTIUM_TEST_ID']
  page.click_button 'Search'
  click_link("#{ENV['ROBOTIUM_TEST_ID']}'s save count:#{record}.")
end

Then(/^I search for all records belonging to this Robotium test$/) do
  page.fill_in 'query', :with => ENV['ROBOTIUM_TEST_ID']
  page.click_button 'Search'
end

# Then(/^I should see all records belonging to this Robotium test$/) do
# end

Then(/^I should see the user registration for this Robotium test$/) do
  # Find the table row with the email address
  email_field = find(:xpath, "//form[@id='user_form']").find(:xpath, "//input[@value = '#{ENV['ROBOTIUM_TEST_ID']}_test2@example.com']")
  row = email_field.find(:xpath, "//../..")
  # Columns 2 and 3 should be first and last name respectively
  fname_field = row.find(:xpath, "//td[2]/input[@value = '#{ENV['ROBOTIUM_TEST_ID']}']")
  lname_field = row.find(:xpath, "//td[3]/input[@value = 'test2']")
end
