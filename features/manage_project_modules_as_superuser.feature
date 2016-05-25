Feature: Manage project modules as a superuser
  In order manage project modules
  As a user
  I want to list, create and edit project modules

  # Note! Most of these steps are duplicated in manage_project_modules_as_user.feature
  # with the exception of differences in user permissions

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  Scenario: View project modules list
    And I have project modules
      | name     |
      | Module 1 |
      | Module 2 |
      | Module 3 |
    Given I am on the home page
    Then I should see project modules
      | name     |
      | Module 1 |
      | Module 2 |
      | Module 3 |

  Scenario: Create a new project module
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims.properties" for "Arch16n"
    And I pick file "style.css" for "CSS"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I can find project module files for "Module 1"

  Scenario: Create a new project module without validation schema or CSS
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I can find project module files for "Module 1"

  Scenario: Create a new project module and set SRID
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I fill in "Module SRID" with "EPSG:4326 - WGS 84"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I can find project module files for "Module 1"
    And I should have setting "srid" for "Module 1" as "4326"

  Scenario Outline: Cannot create project module due to field validation errors
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "<field>" with "<value>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field       | value    | error          |
    | Name        |          | can't be blank |
    | Name        | Module * | is invalid     |
    | Data Schema |          | can't be blank |
    | UI Schema   |          | can't be blank |
    | UI Logic    |          | can't be blank |

  Scenario Outline: Cannot create project module due to file validation errors
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I pick file "<value>" for "<field>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field             | value                     | error                                    |
    | Data Schema       |                           | can't be blank                           |
    | Data Schema       | garbage                   | must be xml file                         |
    | Data Schema       | data_schema_error1.xml    | Premature end of data in tag test line 1 |
    | UI Schema         |                           | can't be blank                           |
    | UI Schema         | garbage                   | must be xml file                         |
    | UI Schema         | ui_schema_error1.xml      | Premature end of data in tag test line 1 |
    | Validation Schema | garbage                   | must be xml file                         |
    | Validation Schema | data_schema_error1.xml    | Premature end of data in tag test line 1 |
    | UI Logic          |                           | can't be blank                           |
    | Arch16n           | faims_Module_2.properties | invalid properties file at line          |
    | CSS               | faims_Module_2.properties | must be css file                         |

  Scenario Outline: Edit module static data
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I fill in "<field>" with "<value>"
    And I press "Update"
    And I should have setting "<setting>" for "Module 1" as "<setting_value>"
  Examples:
    | field          | value              | setting | setting_value |
    | Module SRID    | EPSG:4326 - WGS 84 | srid    | 4326          |
    | Module Version | 1.0                | version | 1.0           |

  Scenario Outline: Edit static data fails due to validation errors
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I fill in "<field>" with "<value>"
    And I press "Update"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field       | value    | error          |
    | Module Name |          | can't be blank |
    | Module Name | Module * | is invalid     |

  Scenario: Edit project module with no new files
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I press "Update"
    Then I should see "Updated module"

  Scenario: Cannot edit project module if project module is locked
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I follow "Module 1"
    And settings is locked for "Module 1"
    Then I follow "Edit Module"
    And I press "Update"
    Then I should see "Could not process request as project is currently locked."

  Scenario: Edit project module with new files
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims.properties" for "Arch16n"
    And I press "Update"
    Then I should see "Updated module"
    And Module "Module 1" should have the same file "ui_schema.xml"
    And Module "Module 1" should have the same file "validation_schema.xml"
    And Module "Module 1" should have the same file "ui_logic.bsh"
    And Module "Module 1" should have the same file "faims.properties"

  Scenario: Edit project module with new file
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I pick file "faims.properties" for "Arch16n"
    And I press "Update"
    Then I should see "Updated module"
    And Module "Module 1" should have the same file "faims.properties"

  Scenario Outline: Cannot edit project module due to file validation errors
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I click on "Module 1"
    Then I follow "Edit Module"
    And I pick file "<value>" for "<field>"
    And I press "Update"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field             | value                     | error                                    |
    | UI Schema         | garbage                   | must be xml file                         |
    | UI Schema         | ui_schema_error1.xml      | Premature end of data in tag test line 1 |
    | Validation Schema | garbage                   | must be xml file                         |
    | Validation Schema | data_schema_error1.xml    | Premature end of data in tag test line 1 |
    | Arch16n           | faims_Module_2.properties | invalid properties file at line          |

  Scenario: Upload Module
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should be on the jobs page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output |
      | 1   | module.tar.bz2      | Upload Module | Pending  |        |
    Then I process delayed jobs
    And I refresh page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output |
      | 1   | module.tar.bz2      | Upload Module | Finished |        |
    Then I follow "modules-tab"
    And I should be on the project modules page
    And I can find project module files for "Simple Project"

  Scenario: Upload Module fails if module already exists
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should be on the jobs page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output |
      | 1   | module.tar.bz2      | Upload Module | Pending  |        |
    Then I process delayed jobs
    And I refresh page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output |
      | 1   | module.tar.bz2      | Upload Module | Finished |        |
    Then I follow "modules-tab"
    And I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should be on the jobs page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output |
      | 2   | module.tar.bz2      | Upload Module | Pending  |        |
      | 1   | module.tar.bz2      | Upload Module | Finished |        |
    Then I process delayed jobs
    And I refresh page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output                                    |
      | 2   | module.tar.bz2      | Upload Module | Failed   | This module already exists in the system. |
      | 1   | module.tar.bz2      | Upload Module | Finished |                                           |

  @javascript
  Scenario: Upload Module fails if module is deleted but already exists
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should be on the jobs page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output |
      | 1   | module.tar.bz2      | Upload Module | Pending  |        |
    Then I process delayed jobs
    And I refresh page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output |
      | 1   | module.tar.bz2      | Upload Module | Finished |        |
    Then I follow "modules-tab"
    And I follow "Simple Project"
    And I follow "Delete Module"
    Then I should see dialog "Are you sure you want to delete module?"
    And I confirm
    And I should see "Module Deleted."
    And I follow "Upload Module"
    And I pick file "module.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should be on the jobs page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output |
      | 2   | module.tar.bz2      | Upload Module | Pending  |        |
      | 1   | module.tar.bz2      | Upload Module | Finished |        |
    Then I process delayed jobs
    And I refresh page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output                                                   |
      | 2   | module.tar.bz2      | Upload Module | Failed   | This module is deleted but already exists in the system. |
      | 1   | module.tar.bz2      | Upload Module | Finished |                                                          |

  Scenario: Upload Module fails if checksum is wrong
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module_corrupted1.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should be on the jobs page
    And I should see "jobs" table with
      | No. | Module / File name        | Job type      | Status   | Output |
      | 1   | module_corrupted1.tar.bz2 | Upload Module | Pending  |        |
    Then I process delayed jobs
    And I refresh page
    And I should see "jobs" table with
      | No. | Module / File name        | Job type      | Status   | Output                         |
      | 1   | module_corrupted1.tar.bz2 | Upload Module | Failed   | Wrong hash sum for the module. |

  Scenario: Upload Module fails if file is corrupted
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module_corrupted2.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should be on the jobs page
    And I should see "jobs" table with
      | No. | Module / File name        | Job type      | Status   | Output |
      | 1   | module_corrupted2.tar.bz2 | Upload Module | Pending  |        |
    Then I process delayed jobs
    And I refresh page
    And I should see "jobs" table with
      | No. | Module / File name        | Job type      | Status   | Output                   |
      | 1   | module_corrupted2.tar.bz2 | Upload Module | Failed   | Failed to upload module. |

  Scenario: Upload Module fails if file is not a module
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module.tar" for "Module File"
    And I press "Upload"
    Then I should be on the jobs page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output |
      | 1   | module.tar          | Upload Module | Pending  |        |
    Then I process delayed jobs
    And I refresh page
    And I should see "jobs" table with
      | No. | Module / File name  | Job type      | Status   | Output                   |
      | 1   | module.tar          | Upload Module | Failed   | Failed to upload module. |

  Scenario: Download package
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I follow "Module 1"
    And I follow "Download Module"
    And I automatically download project module package "Module 1"
    Then I should download project module package file for "Module 1"

  Scenario: Changes cause package to re archive before download
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I follow "Module 1"
    And I make changes to "Module 1"
    And I follow "Download Module"
    And I process delayed jobs
    And I automatically download project module package "Module 1"
    Then I should download project module package file for "Module 1"

  @javascript
  Scenario: Cannot archive package if not enough space
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I follow "Module 1"
    And I make changes to "Module 1"
    And I fake archive size too big
    And I follow "Download Module"
    Then I should be on the jobs page
    Then I should see "jobs" table with
      | No. | Module / File name  | Job type        | Status  | Output |
      | 1   | Module 1            | Archive Module  | Pending |        |
    And I process delayed jobs
    And I refresh page
    Then I should see "jobs" table with
      | No. | Module / File name  | Job type        | Status  | Output                              |
      | 1   | Module 1            | Archive Module  | Failed  | Not enough space to archive module. |

#  @javascript
#  Scenario: Cannot download package if project module is locked
#    Given I have project module "Module 1"
#    And I follow "Show Modules"
#    Then I should be on the project modules page
#    And I follow "Module 1"
#    And database is locked for "Module 1"
#    And I follow "Download Module"
#    And I process delayed jobs
#    Then I should see dialog "Could not process request as project is currently locked."
#    And I confirm

  @javascript
  Scenario: Delete project module
    Given I have project module "Module 1"
    And I have project module "Module 2"
    And I am on the home page
    Then I should be on the project modules page
    And I should see project modules
      | name     |
      | Module 1 |
      | Module 2 |
    And I follow "Module 1"
    And I follow "Delete Module"
    Then I should see dialog "Are you sure you want to delete module?"
    And I confirm
    Then I should be on the project modules page
    And I should see "Module Deleted."
    And I should not see project modules
      | name     |
      | Module 1 |
    And I should see project modules
      | name     |
      | Module 2 |

  @javascript
  Scenario: Cancel deleting project module
    Given I have project module "Module 1"
    And I have project module "Module 2"
    And I am on the home page
    Then I should be on the project modules page
    And I should see project modules
      | name     |
      | Module 1 |
      | Module 2 |
    And I follow "Module 1"
    And I follow "Delete Module"
    Then I should see dialog "Are you sure you want to delete module?"
    And I cancel
    And I am on the project modules page
    Then I should see project modules
      | name     |
      | Module 1 |
      | Module 2 |

  @javascript
  Scenario: Cannot delete project module if project module is locked
    Given I have project module "Module 1"
    And I have project module "Module 2"
    And I am on the home page
    Then I should be on the project modules page
    And I should see project modules
      | name     |
      | Module 1 |
      | Module 2 |
    And I follow "Module 1"
    And settings is locked for "Module 1"
    And I follow "Delete Module"
    Then I should see dialog "Are you sure you want to delete module?"
    And I confirm
    Then I should be on the project modules page
    And I should see "Could not process request as project is currently locked."
    And I am on the project modules page
    Then I should see project modules
      | name     |
      | Module 1 |
      | Module 2 |

  @javascript
  Scenario: Restore project module
    Given I have project module "Module 1"
    And I have project module "Module 2"
    And I am on the home page
    Then I should be on the project modules page
    And I should see project modules
      | name     |
      | Module 1 |
      | Module 2 |
    And I follow "Module 1"
    And I follow "Delete Module"
    Then I should see dialog "Are you sure you want to delete module?"
    And I confirm
    Then I should be on the project modules page
    And I should see "Module Deleted."
    And I am on the project modules page
    And I should not see project modules
      | name     |
      | Module 1 |
    And I should see project modules
      | name     |
      | Module 2 |
    Then I am on the restore project modules page
    And I should see project modules
      | name     |
      | Module 1 |
    And I should not see project modules
      | name     |
      | Module 2 |
    And I click restore for "Module 1"
    Then I should be on the project modules page
    And I should see "Module Restored."
    And I should see project modules
      | name     |
      | Module 1 |
      | Module 2 |