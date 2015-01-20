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
    When I view the file group with title 'Toys'
    And I click on 'Run fixity check'
    Then the file group with title 'Toys' should have an event with key 'fixity_check_requested' performed by 'admin@example.com'
    When delayed jobs are run
    Then the cfs file with name 'picture.jpg' should have events with fields:
      | key           | note | cascadable |
      | fixity_result | OK   | false      |
    And the cfs file with name 'something.txt' should have events with fields:
      | key           | note | cascadable |
      | fixity_result | OK   | false      |
    And the file group with title 'Toys' should have an event with key 'fixity_check_completed' performed by 'admin@example.com'


  Scenario: Fixity check with changed file from file group level
    When the physical cfs directory 'dogs/toy-dogs/yorkies' has a file 'something.txt' with contents 'some changed text'
    And I view the file group with title 'Toys'
    And I click on 'Run fixity check'
    Then the file group with title 'Toys' should have an event with key 'fixity_check' performed by 'admin@example.com'
    When delayed jobs are run
    Then the cfs file with name 'picture.jpg' should have events with fields:
      | key           | note | cascadable |
      | fixity_result | OK   | false      |
    Then the cfs file with name 'something.txt' should have events with fields:
      | key           | note   | cascadable |
      | fixity_result | FAILED | true       |
    And the cfs file at path 'dogs/toy-dogs-yorkies/something.txt' for the file group titled 'Toys' should have 1 red flag
    And the file group with title 'Toys' should have an event with key 'fixity_check_completed' performed by 'admin@example.com'

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

  #These might be better moved to a separate feature for cascadable events
  Scenario: Correct fixity events for files are not visible from file group events
    When PENDING

  Scenario: Incorrect fixity events for files are visible from file group events
    When PENDING

  Scenario: Correct fixity events for files are not visible from directory events
    When PENDING

  Scenario: Incorrect fixity events for files are visible from directory events
    When PENDING

