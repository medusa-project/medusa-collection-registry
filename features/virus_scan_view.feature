Feature: View virus check
  In order to enhance security
  As a librarian
  I want to be able to view the results of a virus check

  Background:
    Given I clear the cfs root directory
    And the cfs directory 'dogs/images' contains cfs fixture file 'clam.exe'
    And the cfs directory 'dogs/images' contains cfs fixture file 'grass.jpg'
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | title  | type              |
      | images | BitLevelFileGroup |
    And the file group titled 'images' has cfs root 'dogs/images' and delayed jobs are run
    And I am logged in as an admin
    And I view the collection with title 'Dogs'
    And I click on 'Run' in the virus-scan actions and delayed jobs are run

  Scenario Outline: View results of a virus check
    When I relogin as a <user_type>
    And I view the collection with title 'Dogs'
    And I click on 'View' in the virus-scan actions and delayed jobs are run
    Then I should see 'images'
    And I should see all of:
      | Infected files: 1 | Scanned files: 2 | dogs/images/clam.exe: Win.Trojan.Trojan-476 FOUND |

    Examples:
      | user_type |
      | admin     |
      | manager   |
      | user      |

