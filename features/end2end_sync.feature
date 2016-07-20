Feature: Check entity sync
  In order to ensure correct Android sync behaviour
  As a user
  I want to view changes made to data synced from my Android

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au" with "Pass.123"

  @end2end
  @mechanize
  Scenario: Verify user registration created during Robotium SignupTest
    Given I am on the project modules page
    And I follow "Sign Up"
    And I follow "Edit Users"
    Then I should see the user registration for this Robotium test

  @end2end
  @mechanize
  Scenario: Verify data synced during Robotium testRun2
    Given I am on the project modules page
    And I follow "Sol1 Hardware"
    And I follow "Search Entity Records"
    And I search for record "1" belonging to this Robotium test
    Then I should see fields with values
      | field            | Constrained Data | Unconstrained Data |
      | Customer         | {Sol1}           |                    |
      | Manufacture Date |                  | 1980               |
      | Make             |                  | save               |
      | Model            |                  | count:1.           |
      | Serial           |                  | 1001               |

  @end2end
  @mechanize
  Scenario: Verify data synced during Robotium testRun4
    Given I am on the project modules page
    And I follow "Sol1 Hardware"
    And I follow "Search Entity Records"
    And I search for record "2" belonging to this Robotium test
    Then I should see fields with values
      | field            | Constrained Data | Unconstrained Data |
      | Customer         | {Sol1}           |                    |
      | Model            |                  | count:2.           |
      | Serial           |                  | 123456790124       |

  @end2end
  @mechanize
  Scenario: Verify data synced during Robotium testRun4
    Given I am on the project modules page
    And I follow "Sol1 Hardware"
    And I follow "Search Entity Records"
    And I search for all records belonging to this Robotium test
    And I select "100" from "per_page"
    Then I should see records
      | name                         |
      | 132_1446_ua's save count:1.  |
      | 132_1446_ua's save count:2.  |
      | 132_1446_ua's save count:11. |
      | 132_1446_ua's save count:12. |
      | 132_1446_ua's save count:13. |
      | 132_1446_ua's save count:14. |
      | 132_1446_ua's save count:15. |
      | 132_1446_ua's save count:16. |
      | 132_1446_ua's save count:17. |
      | 132_1446_ua's save count:18. |
      | 132_1446_ua's save count:19. |
      | 132_1446_ua's save count:20. |
      | 132_1446_ua's save count:21. |
      | 132_1446_ua's save count:22. |
      | 132_1446_ua's save count:23. |
      | 132_1446_ua's save count:24. |
      | 132_1446_ua's save count:25. |
      | 132_1446_ua's save count:26. |
      | 132_1446_ua's save count:27. |
      | 132_1446_ua's save count:28. |
      | 132_1446_ua's save count:29. |
      | 132_1446_ua's save count:30. |
      | 132_1446_ua's save count:31. |
      | 132_1446_ua's save count:32. |
      | 132_1446_ua's save count:33. |
      | 132_1446_ua's save count:34. |
      | 132_1446_ua's save count:35. |
      | 132_1446_ua's save count:36. |
      | 132_1446_ua's save count:37. |
      | 132_1446_ua's save count:38. |
      | 132_1446_ua's save count:39. |
      | 132_1446_ua's save count:40. |
      | 132_1446_ua's save count:41. |
      | 132_1446_ua's save count:42. |
      | 132_1446_ua's save count:43. |
      | 132_1446_ua's save count:44. |
      | 132_1446_ua's save count:45. |
      | 132_1446_ua's save count:46. |
      | 132_1446_ua's save count:47. |
      | 132_1446_ua's save count:48. |
      | 132_1446_ua's save count:49. |
      | 132_1446_ua's save count:50. |
      | 132_1446_ua's save count:51. |
      | 132_1446_ua's save count:52. |
      | 132_1446_ua's save count:53. |
      | 132_1446_ua's save count:54. |
      | 132_1446_ua's save count:55. |
      | 132_1446_ua's save count:56. |
      | 132_1446_ua's save count:57. |
      | 132_1446_ua's save count:58. |
      | 132_1446_ua's save count:59. |