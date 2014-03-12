Feature: View virus check
  In order to enhance security
  As a librarian
  I want to be able to view the results of a virus check

  Background:
    Given PENDING
    Given I clear the cfs root directory
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | name   | type              |
      | images | BitLevelFileGroup |
    And the file group named 'images' has cfs root 'dogs/images'
    And the cfs directory 'dogs/images' contains cfs fixture file 'clam.exe'
    And the cfs directory 'dogs/images' contains cfs fixture file 'grass.jpg'
    And I am logged in as an admin
    And I view the collection titled 'Dogs'
    And I click on 'Run' in the virus-scan actions

  Scenario: View results of a virus check as an admin
    And I view the collection titled 'Dogs'
    And I click on 'View Latest' in the virus-scan actions
    Then I should see 'images'
    And I should see all of:
      | Infected files: 1 | Scanned files: 2 | dogs/images/clam.exe: ClamAV-Test-File FOUND |

  Scenario: View results of a virus check as a manager
    When I relogin as a manager
    And I view the collection titled 'Dogs'
    And I click on 'View Latest' in the virus-scan actions
    Then I should see 'images'
    And I should see all of:
      | Infected files: 1 | Scanned files: 2 | dogs/images/clam.exe: ClamAV-Test-File FOUND |

  Scenario: View results of a virus check as a visitor
    When I relogin as a visitor
    And I view the collection titled 'Dogs'
    And I click on 'View Latest' in the virus-scan actions
    Then I should see 'images'
    And I should see all of:
      | Infected files: 1 | Scanned files: 2 | dogs/images/clam.exe: ClamAV-Test-File FOUND |
