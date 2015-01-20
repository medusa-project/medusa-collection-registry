Feature: Fixity Checking
  In order to ensure continuing integrity of files
  As a repository administrator
  I want to be able to run fixity checks on my file

  Background:
    Given I am logged in as an admin
    And I clear the cfs root directory
    And the physical cfs directory 'dogs/toy-dogs' has a file 'picture.jpg' with contents 'picture stuff'
    And the physical cfs directory 'dogs/toy-dogs/yorkies' has a file 'something.txt' with contents 'some text'
    And the collection with title 'Dogs' has child file groups with fields:
      | title   | type              |
      | Toys    | BitLevelFileGroup |
      | Workers | BitLevelFileGroup |
    And the file group titled 'Toys' has cfs root 'dogs/toy-dogs' and delayed jobs are run

  Scenario: Fixity check against unchanged files from file group level
    When PENDING

  Scenario: Fixity check with changed file from file group level
    When PENDING

  Scenario: File group without cfs root doesn't have a fixity check link
    When I view the file group with title 'Workers'
    Then I should not see 'Run fixity check'

  Scenario: Fixity check against unchanged files from directory level
    When PENDING

  Scenario: Fixity check with changed file from directory level
    When PENDING

  Scenario: Fixity check of unchanged file from file level
    When PENDING

  Scenario: Fixity check of changed file from file level
    When PENDING

  Scenario: Visitors and public cannot order fixity checks
    When PENDING

  Scenario: Correct fixity events for files are not visible from file group events
    When PENDING

  Scenario: Incorrect fixity events for files are visible from file group events
    When PENDING

  Scenario: Correct fixity events for files are not visible from directory events
    When PENDING

  Scenario: Incorrect fixity events for files are visible from directory events
    When PENDING

