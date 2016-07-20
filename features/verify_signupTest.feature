Feature: Verify robotium SignupTest
  Verify the signed up users on the server
  created by the robotium SignupTest 
  are correct

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  @javascript
  Scenario: verify testRun2 
    Given I have project module "Sign up"
    And I am on the project modules page
    And I follow "Sign Up"
    And I follow "Edit Users"
    Then I should see "$RUNID$_test2@example.com"
    Then I should see fields with values
      | field  | type       | values                    |
      |        | Email      | $RUNID$_test2@example.com |
      |        | First Name | $RUNID$                   |
      |        | Last Name  | test2                     |
   

