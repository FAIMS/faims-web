Feature: Verify robotium RecordsTest
  Verify the records on the server
  created by the robotium RecordsTest 
  are correct

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  @javascript
  Scenario: verify testRun2 
    Given I have project module "Sol1 Hardware"
    And I am on the project modules page
    And I follow "Sol1 Hardware"
    And I follow "Search Entity Records"
    And I enter "$RUNID$" and submit the form
    And I follow "$RUNID$'s save count:1."
    Then I should see fields with values
      | field    | type               | values   |
      | Customer | Constrained Data   | Sol1     |
      | Owner    | Unconstrained Data | $RUNID$  |
      | Model    | Unconstrained Data | count:1. |
      | Serial   | Unconstrained Data | 1001     |


  @javascript
  Scenario: verify testRun4
    Given I press "Back"
    And I follow "$RUNID$'s save count:2."
    Then I should see fields with values
      | field    | type               | values       |
      | Customer | Constrained Data   | Sol1         |
      | Owner    | Unconstrained Data | $RUNID$      |
      | Model    | Unconstrained Data | count:2.     |
      | Serial   | Unconstrained Data | 123456790124 |


   @javascript
  Scenario: verify testRun5
    Given I press "Back"
    And I select "100" from "per_page"
    Then I should see records
      | name                     |
      | $RUNID$'s save count:1.  |
      | $RUNID$'s save count:2.  |
      | $RUNID$'s save count:11. |
      | $RUNID$'s save count:12. |
      | $RUNID$'s save count:13. |
      | $RUNID$'s save count:14. |
      | $RUNID$'s save count:15. |
      | $RUNID$'s save count:16. |
      | $RUNID$'s save count:17. |
      | $RUNID$'s save count:18. |
      | $RUNID$'s save count:19. |
      | $RUNID$'s save count:20. |
      | $RUNID$'s save count:21. |
      | $RUNID$'s save count:22. |
      | $RUNID$'s save count:23. |
      | $RUNID$'s save count:24. |
      | $RUNID$'s save count:25. |
      | $RUNID$'s save count:26. |
      | $RUNID$'s save count:27. |
      | $RUNID$'s save count:28. |
      | $RUNID$'s save count:29. |
      | $RUNID$'s save count:30. |
      | $RUNID$'s save count:31. |
      | $RUNID$'s save count:32. |
      | $RUNID$'s save count:33. |
      | $RUNID$'s save count:34. |
      | $RUNID$'s save count:35. |
      | $RUNID$'s save count:36. |
      | $RUNID$'s save count:37. |
      | $RUNID$'s save count:38. |
      | $RUNID$'s save count:39. |
      | $RUNID$'s save count:40. |
      | $RUNID$'s save count:41. |
      | $RUNID$'s save count:42. |
      | $RUNID$'s save count:43. |
      | $RUNID$'s save count:44. |
      | $RUNID$'s save count:45. |
      | $RUNID$'s save count:46. |
      | $RUNID$'s save count:47. |
      | $RUNID$'s save count:48. |
      | $RUNID$'s save count:49. |
      | $RUNID$'s save count:50. |
      | $RUNID$'s save count:51. |
      | $RUNID$'s save count:52. |
      | $RUNID$'s save count:53. |
      | $RUNID$'s save count:54. |
      | $RUNID$'s save count:55. |
      | $RUNID$'s save count:56. |
      | $RUNID$'s save count:57. |
      | $RUNID$'s save count:58. |
      | $RUNID$'s save count:59. |


