@idb
Feature: Ingest IDB file
  In order to preserve IDB files
  As IDB
  I want to be able to tell Medusa to ingest a file and have it go to preservation storage

  Scenario: Medusa receives message from IDB and creates delayed job to ingest
    When IDB sends an ingest request
    And Medusa picks up the IDB ingest request
    Then there should be an IDB ingest delayed job reflecting the ingest request

  Scenario: Medusa runs delayed job for IDB ingest, ingesting file and returning message to IDB
    Given there is an IDB ingest delayed job
    And there is an IDB file group
    When the IDB ingest delayed job is run
    Then the IDB files should be present in medusa storage
    And Medusa should have sent a return message to IDB