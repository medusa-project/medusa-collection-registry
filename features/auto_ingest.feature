Feature: Automatic ingestion from staged to bit level
  In order to streamline the ingestion workflow
  As a librarian
  I want to be able to ingest staged file groups automatically

  Background:
    Given I am logged in as an admin

  Scenario: There is a button to start the process if the group is ready for ingestion
    Given an external file group with name 'stuff' is staged with bag data 'small-bag'
    When I view the external file group with name 'stuff'
    Then I should see 'Approve for ingest'

  Scenario: There is not a button to start the process if there is a related bit level file group
    Given an external file group with name 'stuff' is staged with bag data 'small-bag'
    And the external file group with name 'stuff' has a related bit level file group
    When I view the external file group with name 'stuff'
    Then I should not see 'Approve for ingest'

  Scenario: There is not a button to start the process if there is no corresponding directory in staging storage
    Given the external file group with name 'stuff' exists
    When I view the external file group with name 'stuff'
    Then I should not see 'Approve for ingest'

  Scenario: There is not a button to start the process if an ingest has already been started
    Given an external file group with name 'stuff' is staged with bag data 'small-bag'
    And the external file group with name 'stuff' is already being ingested
    Then I should not see 'Approve for ingest'