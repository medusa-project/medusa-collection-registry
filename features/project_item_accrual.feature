Feature: Project Item Accrual
  In order to get content into medusa
  As digitization staff
  I want to be able to import project items as they are finished

  @javascript @search
  Scenario: Create project item ingest from the project page
    Given the project with title 'Scanning' has child items with fields:
      | id | unique_identifier | bib_id | ingested |
      | 1  | item_1            |        | false    |
      | 2  |                   | item_2 | false    |
      | 3  | item_3            |        | false    |
      | 4  | item_4            |        | true     |
    And I am logged in as a project_mgr
    When I view the project with title 'Scanning'
    And I click on 'check_all'
    And I click on 'Ingest items'
    And I wait for 1 of 'Workflow::ProjectItemIngest' to exist
    Then the project item ingest workflow for the project with title 'Scanning' should have items with ingest identifier:
      | item_1 | item_2 | item_3 |
    And the project item ingest workflow for the project with title 'Scanning' should not have items with ingest identifier:
      | item_4 |
    And the project item ingest workflow for the project with title 'Scanning' should have user 'project_mgr@example.com'

  Scenario: Receive email that ingest is starting
    Given the user 'manager@example.com' has a project item ingest workflow in state 'email_started'
    When I perform project item ingest workflows
    Then 'manager@example.com' should receive an email with subject 'Medusa: Project Item ingest started'
    And there should be 1 project item ingest workflow in state 'ingest'
    And there should be 1 project item ingest workflow delayed job

  #this requires quite a bit of setup
  Scenario: Ingest items with no errors
    Given every collection with fields exists:
      | title   | id |
      | Animals | 1  |
    And every bit level file group with fields exists:
      | title | collection_id | id |
      | Dogs  | 1             | 1  |
    And the uuid of the cfs directory with path '1/1' is '2c90f940-c6e1-0134-cb7e-0c4de9bac164-5'
    And every project with fields exists:
      | title   | ingest_folder | destination_folder_uuid                | collection_id |
      | Animals | dog_ingest    | 2c90f940-c6e1-0134-cb7e-0c4de9bac164-5 | 1             |
    And the project with title 'Animals' has child items with fields:
      | unique_identifier | bib_id |
      | item_1            |        |
      |                   | item_2 |
      | item_3            |        |
    And there is a project item ingest workflow for the project with title 'Animals' in state 'ingest' for items with ingest identifier:
      | item_1 | item_2 |
    And there exists staged content for the items with ingest identifiers:
      | item_1 | item_2 |
    When I perform project item ingest workflows
    Then the items with fields should exist:
      | unique_identifier | bib_id | ingested |
      | item_1            |        | true     |
      |                   | item_2 | true     |
      | item_3            |        | false    |
    And the cfs directory with path '1/1' should have associated subdirectories with field path:
      | item_1 | item_2 |
    And the cfs directory with path 'item_1' should have associated cfs files with field name:
      | content.txt |
    And the cfs directory with path 'item_2' should have associated cfs files with field name:
      | content.txt |
    And the bit level file group with title 'Dogs' should have events with fields:
      | key                 |
      | project_item_ingest |
    And there should be 1 project item ingest workflow in state 'email_progress'

  Scenario: Email progress
    Given the user 'manager@example.com' has a project item ingest workflow in state 'email_progress'
    When I perform project item ingest workflows
    Then 'manager@example.com' should receive an email with subject 'Medusa: Project Item ingest progress'
    And there should be 1 project item ingest workflow in state 'amazon_backup'
    And there should be 1 project item ingest workflow delayed job

    #Since the setup is a little complex we combine the test for requesting and receive notice of amazon backup
  Scenario: Ingest request amazon backup and receive notice of amazon backup
    Given every collection with fields exists:
      | title   | id |
      | Animals | 1  |
    And every bit level file group with fields exists:
      | title | collection_id | id |
      | Dogs  | 1             | 1  |
    And the uuid of the cfs directory with path '1/1' is '2c90f940-c6e1-0134-cb7e-0c4de9bac164-5'
    And every project with fields exists:
      | title   | destination_folder_uuid                | collection_id |
      | Animals | 2c90f940-c6e1-0134-cb7e-0c4de9bac164-5 | 1             |
    And the project with title 'Animals' has child items with fields:
      | unique_identifier |
      | item_1            |
    And there is a project item ingest workflow for the project with title 'Animals' in state 'amazon_backup' for items with ingest identifier:
      | item_1 |
    When I perform project item ingest workflows
    Then there should be 1 project item ingest workflow in state 'amazon_backup'
    And there should be 0 project item ingest workflow delayed jobs
    And there should be 1 amazon backup delayed job
    When delayed jobs are run
    And amazon backup runs successfully
    Then there should be 1 project item ingest workflow in state 'amazon_backup_completed'
    Then there should be 0 project item ingest workflows in state 'amazon_backup'
    And there should be 1 project item ingest workflow delayed job
    And the file group titled 'Dogs' should have a completed Amazon backup

  Scenario: Ingest process amazon backup completed
    Given the user 'manager@example.com' has a project item ingest workflow in state 'amazon_backup_completed'
    When I perform project item ingest workflows
    And there should be 1 project item ingest workflow in state 'email_done'
    And there should be 1 project item ingest workflow delayed job

  Scenario: Try ingest with staging directory not existing
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
    And there is a project item ingest workflow for the project with title 'Animals' in state 'ingest' for items with ingest identifier:
      | item_1 |
    When I perform project item ingest workflows
    Then there should be 1 project item ingest workflow in state 'email_staging_directory_missing'

  Scenario: Email about missing staging directory
    Given the user 'manager@example.com' has a project item ingest workflow in state 'email_staging_directory_missing'
    When I perform project item ingest workflows
    Then 'manager@example.com' should receive an email with subject 'Medusa: Project Item ingest error' containing all of:
      | The staging directory was either not specified or does not exist on disk. |
    And there should be 1 project item ingest workflow in state 'end'

  Scenario: Try ingest with target cfs directory not specified or not existing
    Given every collection with fields exists:
      | title   | id |
      | Animals | 1  |
    Given every bit level file group with fields exists:
      | title | collection_id | id |
      | Dogs  | 1             | 1  |
    And the uuid of the cfs directory with path '1/1' is '2c90f940-c6e1-0134-cb7e-0c4de9bac164-5'
    And every project with fields exists:
      | title   | ingest_folder | destination_folder_uuid | collection_id |
      | Animals | dog_ingest    | something_else          | 1             |
    And the project with title 'Animals' has child items with fields:
      | unique_identifier |
      | item_1            |
    And there is a project item ingest workflow for the project with title 'Animals' in state 'ingest' for items with ingest identifier:
      | item_1 |
    And there exists staged content for the items with ingest identifiers:
      | item_1 |
    When I perform project item ingest workflows
    Then there should be 1 project item ingest workflow in state 'email_target_directory_missing'

  Scenario: Email about missing target directory
    Given the user 'manager@example.com' has a project item ingest workflow in state 'email_target_directory_missing'
    When I perform project item ingest workflows
    Then 'manager@example.com' should receive an email with subject 'Medusa: Project Item ingest error' containing all of:
      | The target cfs directory either does not exist or belongs to the wrong collection. |
    And there should be 1 project item ingest workflow in state 'end'

  Scenario: Try to ingest item without staging directory
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
    And there is a project item ingest workflow for the project with title 'Animals' in state 'ingest' for items with ingest identifier:
      | item_1 |
    And there exists staged content for the items with ingest identifiers:
      | item_2 |
    When I perform project item ingest workflows
    Then the items with fields should exist:
      | unique_identifier | ingested |
      | item_1            | false    |
    And the cfs directory with path '1/1' should not have associated subdirectories with field path:
      | item_1 |
    And there should be 1 project item ingest workflow in state 'email_progress'

  Scenario: Receive email that ingest has happened
    Given the user 'manager@example.com' has a project item ingest workflow in state 'email_done'
    When I perform project item ingest workflows
    Then 'manager@example.com' should receive an email with subject 'Medusa: Project Item ingest completed'
    And there should be 1 project item ingest workflow in state 'end'
    And there should be 1 project item ingest workflow delayed job

  Scenario: Remove finished ingest job
    Given there is a project item ingest workflow in state 'end'
    When I perform project item ingest workflows
    Then there should be 0 project item ingest workflows
