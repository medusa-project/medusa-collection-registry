@idb
Feature: Amqp accrual
  In order to preserve files from clients such as IDB
  As a client application
  I want to be able to tell Medusa to ingest a file and have it go to preservation storage

  Background:
    Given there is an IDB file group

  Scenario: Medusa receives message from IDB and creates delayed job to ingest
    When IDB sends an ingest request
    And Medusa picks up the IDB ingest request
    Then there should be an IDB ingest delayed job reflecting the ingest request

  Scenario: Medusa runs delayed job for IDB ingest, ingesting file and returning message to IDB
    And there is an IDB ingest delayed job
    When the IDB ingest delayed job is run
    Then the IDB files should be present in medusa storage
    And Medusa should have sent a return message to IDB