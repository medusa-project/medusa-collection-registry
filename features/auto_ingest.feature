Feature: Automatic ingestion from staged to bit level
  In order to streamline the ingestion workflow
  As a librarian
  I want to be able to ingest staged file groups automatically

  Background:
    Given I am logged in as an admin

  Scenario: There is a button to start the process if the group is ready for ingestion
    Given an external file group with title 'stuff' in collection 'things' is staged with bag data 'small-bag'
    When I view the external file group with title 'stuff'
    And I click on 'Approve for ingest'
    Then the external file group with title 'stuff' should be in the process of ingestion
    And a bit_level_file_group with title 'stuff' should exist
    And the external file group with title 'stuff' should have a related bit level file group titled 'stuff' with relation note 'Created by automatic ingest'
    When delayed jobs are run
    Then the file group titled 'stuff' should have a cfs directory
    And the file group titled 'stuff' should have a cfs file for the path 'stuff/more.txt' with results:
      | name | more.txt |
    And The collection titled 'things' should have preservation priority 'ingested'
    And there should be 1 amazon backup delayed job
    When amazon backup runs successfully
    Then the file group titled 'stuff' should have a completed Amazon backup
    And 'admin@example.com' should receive an email with subject 'Amazon backup progress'
    And the external file group with title 'stuff' should be in the process of ingestion
    When delayed jobs are run
    Then the external file group with title 'stuff' should not be in the process of ingestion
    And 'admin@example.com' should receive an email with subject 'Medusa ingest completed'
    And there should be a staging deletion job for the external file group titled 'stuff'
    And I wait 2 seconds
    When delayed jobs are run
    Then the external file group with title 'stuff' should have no staged content
    And 'admin@example.com' should receive an email with subject 'Staged Medusa content deleted'

  Scenario: There is not a button to start the process if there is a related bit level file group
    Given an external file group with title 'stuff' in collection 'things' is staged with bag data 'small-bag'
    And the external file group with title 'stuff' has a related bit level file group
    When I view the external file group with title 'stuff'
    Then I should not see 'Approve for ingest'

  Scenario: There is not a button to start the process if there is no corresponding directory in staging storage
    Given the external file group with title 'stuff' exists
    When I view the external file group with title 'stuff'
    Then I should not see 'Approve for ingest'

  Scenario: There is not a button to start the process if an ingest has already been started
    Given an external file group with title 'stuff' in collection 'things' is staged with bag data 'small-bag'
    And the external file group with title 'stuff' is already being ingested
    When I view the external file group with title 'stuff'
    Then I should not see 'Approve for ingest'

  Scenario: There is not a button to start the process unless I am an admin
    Given an external file group with title 'stuff' in collection 'things' is staged with bag data 'small-bag'
    And I relogin as a manager
    When I view the external file group with title 'stuff'
    Then I should not see 'Approve for ingest'
