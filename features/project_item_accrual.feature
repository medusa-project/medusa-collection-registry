Feature: Project Item Accrual
  In order to get content into medusa
  As digitization staff
  I want to be able to import project items as they are finished

  @javascript @search
  Scenario: Create project item ingest from the project page
    Given the project with title 'Scanning' has child items with fields:
      | id | unique_identifier | ingested |
      | 1  | item_1            | false    |
      | 2  | item_2            | false    |
      | 3  | item_3            | false    |
      | 4  | item_4            | true     |
    And I am logged in as a manager
    When I view the project with title 'Scanning'
    And I click on 'check_all'
    And I click on 'Ingest items'
    And I wait for 1 of 'Workflow::ProjectItemIngest' to exist
    Then the project item ingest workflow for the project with title 'Scanning' should have items with unique_identifier:
      | item_1 | item_2 | item_3 |
    And the project item ingest workflow for the project with title 'Scanning' should not have items with unique_identifier:
      | item_4 |
    And the project item ingest workflow for the project with title 'Scanning' should have user 'manager@example.com'

  #TODO more information about the ingest request
  Scenario: Receive email that ingest is starting
    Given the user 'manager@example.com' has a project item ingest workflow in state 'email_started'
    When I perform project item ingest workflows
    Then 'manager@example.com' should receive an email with subject 'Project Item ingest started'
    And there should be 1 project item ingest workflow in state 'ingest'
    And there should be 1 project item ingest workflow delayed job

  #this requires quite a bit of setup
  Scenario: Ingest items with no errors
    Given every collection with fields exists:
      | title   | id |
      | Animals | 1  |
    Given every bit level file group with fields exists:
      | title | collection_id | id |
      | Dogs  | 1             | 1  |
    And the uuid of the cfs directory with path '1/1' is '2c90f940-c6e1-0134-cb7e-0c4de9bac164-5'
    And every project with fields exists:
      | title   | ingest_folder | destination_folder_uuid                | collection_id |
      | Animals | dog_ingest    | 2c90f940-c6e1-0134-cb7e-0c4de9bac164-5 | 1             |
    And the project with title 'Animals' has child items with fields:
      | unique_identifier |
      | item_1            |
      | item_2            |
      | item_3            |
    And there exists staged content for the items with unique identifiers:
      | item_1 | item_2 |
    And there is a project item ingest workflow for the project with title 'Animals' in state 'ingest' for items with unique identifier:
      | item_1 | item_2 |
    When I perform project item ingest workflows
    Then the items with fields should exist:
      | unique_identifier | ingested |
      | item_1            | true     |
      | item_2            | true     |
      | item_3            | false    |
    And the cfs directory with path '1/1' should have associated subdirectories with field path:
      | item_1 | item_2 |
    And the cfs directory with path 'item_1' should have associated cfs files with field name:
      | content.txt |
    And the cfs directory with path 'item_2' should have associated cfs files with field name:
      | content.txt |
    And there should be 1 project item ingest workflows in state 'email_done'

  Scenario: Try ingest with staging directory not existing
    When PENDING

  Scenario: Try ingest with target cfs directory not specified or not existing
    When PENDING

  Scenario: Try to ingest item without staging directory
    When PENDING

  Scenario: Receive email that ingest has happened
    Given the user 'manager@example.com' has a project item ingest workflow in state 'email_done'
    When I perform project item ingest workflows
    Then 'manager@example.com' should receive an email with subject 'Project Item ingest completed'
    And there should be 1 project item ingest workflow in state 'end'
    And there should be 1 project item ingest workflows delayed job

  Scenario: Remove finished ingest job
    Given there is a project item ingest workflow in state 'end'
    When I perform project item ingest workflows
    Then there should be 0 project item ingest workflows
