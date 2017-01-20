Feature: Project Item Accrual
  In order to get content into medusa
  As digitization staff
  I want to be able to import project items as they are finished

  Background:
    When PENDING

  Scenario: Create project item ingest from the project page
    When PENDING
    #go to page, check some items, hit button
    #check that workflow is created

  Scenario: Receive email that ingest is starting
    When PENDING
    #workflow in appropriate state
    #perform
    #make sure email is sent, workflow is in new state

  Scenario: Ingest items with no errors
    When PENDING
    #workflow in appropriate state
    #perform
    #make sure that items are ingested and marked as such
    #workflow is in new state
    #we've recorded item status for email

  Scenario: Ingest items with existing items
    #workflow in appropriate state
    #perform
    #make sure that duplicate items are not ingested
    #workflow is in new state
    #we've recorded item status for email

  Scenario: Receive email that ingest has happened
    When PENDING
    #workflow in appropriate state
    #perform
    #email is sent, workflow is in new state

  Scenario: Remove finished ingest job
    When PENDING
    #workflow in appropriate state
    #perform
    #job is removed
