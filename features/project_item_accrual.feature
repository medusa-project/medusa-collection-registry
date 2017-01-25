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

  Scenario: Ingest items with no errors
    When PENDING
    #set up - we need a project with items with content on the file system
    #- a file group/directory to accrue to and a workflow request in the system
    #at the end we want to see the right stuff in the db and on the file system
    #perform
    #make sure that items are ingested and marked as such
    #workflow is in new state
    #we've recorded item status for email

  Scenario: Ingest items with existing items
    When PENDING
    #workflow in appropriate state
    #perform
    #make sure that duplicate items are not ingested
    #workflow is in new state
    #we've recorded item status for email

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
