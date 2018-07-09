@javascript
Feature: Dashboard running processes display
  In order to track batch jobs that I've started
  As a librarian
  I want to have a dashboard display of running processes

  Background:
    Given I am logged in as an admin
    Given the collection with title 'Animals' has child file groups with fields:
      | title  | type              |
      | Dogs  | BitLevelFileGroup |
      | Cats  | BitLevelFileGroup |
      | Gnats | BitLevelFileGroup |
      | Bats  | ExternalFileGroup |

  Scenario: See running initial assessment characterizations
    Given the main storage has a directory key 'files/dogs' containing a file
    And the main storage has a directory key 'files/cats' containing a file
    And the file group titled 'Dogs' has cfs root 'files/dogs'
    And the file group titled 'Cats' has cfs root 'files/cats'
    And I am running an initial assessment job for the file group titled 'Dogs' with 12 files
    And I am running an initial assessment job for the file group titled 'Cats' with 13 files
    When I go to the dashboard
    And I click on 'Running Processes'
    Then I should see the running initial assessment scans table
    And I should see all of:
      | Dogs | Cats | files/dogs | files/cats | 12 | 13 |
    And I should see none of:
      | Gnats | Bats |

  Scenario: Display failed job count
    Given there are 2 failed delayed jobs
    When I go to the dashboard
    And I click on 'Running Processes'
    Then I should see '2 delayed jobs have failed'