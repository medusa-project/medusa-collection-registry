Feature: Fixity Checking
  In order to ensure continuing integrity of files
  As a repository administrator
  I want to be able to run fixity checks on my file

  Background:
    Given the main storage has a key 'dogs/toy-dogs/picture.doc' with contents 'picture stuff'
    And the main storage has a key 'dogs/toy-dogs/yorkies/something.txt' with contents 'some text'
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | title   | type              |
      | Toys    | BitLevelFileGroup |
      | Workers | BitLevelFileGroup |
    And the file group titled 'Toys' has cfs root 'dogs/toy-dogs' and delayed jobs are run

  @javascript @search
  Scenario: Failed fixity events are visible all the way up to the repository level
    Given the cfs file with name 'something.txt' has events with fields:
      | key           | note   | actor_email       | cascadable |
      | fixity_result | FAILED | admin@example.com | true       |
    And I am logged in as an admin
    When I view the cfs directory for the file group titled 'Toys' for the path '.'
    And I click on 'Events'
    And I click on 'View Events'
    Then I should see all of:
      | Fixity result | FAILED | something.txt |
    When I view the file group with title 'Toys'
    And I click on 'Events'
    And I click on 'View Events'
    Then I should see all of:
      | Fixity result | FAILED | something.txt |
    When I view the collection with title 'Dogs'
    And I click on 'Events'
    Then I should see all of:
      | Fixity result | FAILED | something.txt |
    When I view the repository with title 'Animals'
    And I click on 'Events'
    Then I should see all of:
      | Fixity result | FAILED | something.txt |
