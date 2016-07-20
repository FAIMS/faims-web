Feature: Check entity sync
  In order to provide android interactions
  As a user
  I want to view changes made to entities from my android

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  @end2end
  @javascript
  Scenario: Update entity with auto saving
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "Search Entity Records"
    And I press "Search"
    And I follow "Small 2"
    And I update fields with values
      | field    | type               | values                 |
      | location | Constrained Data   | Location A; Location C |
      | name     | Annotation         | test3                  |
      | name     | Certainty          |                        |
      | value    | Unconstrained Data | 10.0                   |
      | value    | Certainty          | 0.5                    |
    Then I should see "Successfully updated entity"
    And I refresh page
    And I should see fields with values
      | field    | type               | values                 |
      | location | Constrained Data   | Location A; Location C |
      | name     | Annotation         | test3                  |
      | name     | Certainty          |                        |
      | value    | Unconstrained Data | 10.0                   |
      | value    | Certainty          | 0.5                    |
