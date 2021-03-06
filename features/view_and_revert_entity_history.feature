Feature: View and Revert entity history
  In order view and revert entity history
  As a user
  I want to view and revert entity history

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  @ignore_jenkins
  @javascript
  Scenario: Resolve entity conflicts
    Given I have project module "Resolve Conflicts"
    And I am on the project modules page
    And I follow "Resolve Conflicts"
    And I follow "Search Entity Records"
    And I press "Search"
    Then I should see "Small 1" with "conflict"
    And I follow "Small 1"
    Then I should see "This Entity record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    And I follow "Show History"
    Then I history should have conflicts
    And I click on "Revert and Resolve Conflicts"
    Then I history should not have conflicts

  @ignore_jenkins
  @javascript
  Scenario: Cannot resolve conflicts if database is locked
    Given I have project module "Resolve Conflicts"
    And I am on the project modules page
    And I follow "Resolve Conflicts"
    And I follow "Search Entity Records"
    And I press "Search"
    Then I should see "Small 1" with "conflict"
    And I follow "Small 1"
    Then I should see "This Entity record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    And I follow "Show History"
    Then I history should have conflicts
    And database is locked for "Resolve Conflicts"
    And I click on "Revert and Resolve Conflicts"
    And I should see "Could not process request as project is currently locked."
    Then I history should have conflicts

  @ignore_jenkins
  @javascript
  Scenario: Cannot resolve conflicts if not member of module
    Given I logout
    And I have a user "other@intersect.org.au" with role "superuser"
    And I am logged in as "other@intersect.org.au"
    And I have project module "Resolve Conflicts"
    And I am on the project modules page
    And I follow "Resolve Conflicts"
    And I follow "Search Entity Records"
    And I press "Search"
    Then I should see "Small 1" with "conflict"
    And I follow "Small 1"
    Then I should see "This Entity record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    And I follow "Show History"
    Then I history should have conflicts
    And I click on "Revert and Resolve Conflicts"
    Then I should see "You are not a member of the module you are editing. Please ask a member to add you to the module before continuing."
    Then I history should have conflicts