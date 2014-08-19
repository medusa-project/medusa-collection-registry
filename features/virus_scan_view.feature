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
      | name   | type              |
      | images | BitLevelFileGroup |
    And the file group named 'images' has cfs root 'dogs/images' and delayed jobs are run
    And I am logged in as an admin
    And I view the collection with title 'Dogs'
    And I click on 'Run' in the virus-scan actions and delayed jobs are run

  Scenario: View results of a virus check as an admin
    And I view the collection with title 'Dogs'
    And I click on 'View Latest' in the virus-scan actions and delayed jobs are run
    Then I should see 'images'
    And I should see all of:
      | Infected files: 1 | Scanned files: 2 | dogs/images/clam.exe: ClamAV-Test-File FOUND |

  Scenario: View results of a virus check as a manager
    When I relogin as a manager
    And I view the collection with title 'Dogs'
    And I click on 'View Latest' in the virus-scan actions and delayed jobs are run
    Then I should see 'images'
    And I should see all of:
      | Infected files: 1 | Scanned files: 2 | dogs/images/clam.exe: ClamAV-Test-File FOUND |

  Scenario: View results of a virus check as a visitor
    When I relogin as a visitor
    And I view the collection with title 'Dogs'
    And I click on 'View Latest' in the virus-scan actions and delayed jobs are run
    Then I should see 'images'
    And I should see all of:
      | Infected files: 1 | Scanned files: 2 | dogs/images/clam.exe: ClamAV-Test-File FOUND |
