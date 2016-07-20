Feature: Check entity sync
  In order to ensure correct Android sync behaviour
  As a user
  I want to view changes made to data synced from my Android

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au" with "Pass.123"

  @end2end_signup
  @mechanize
  Scenario: Verify user registration created during Robotium SignupTest
    Given I am on the project modules page
    And I follow "Sign Up"
    And I follow "Edit Users"
    Then I should see the user registration for this Robotium test
