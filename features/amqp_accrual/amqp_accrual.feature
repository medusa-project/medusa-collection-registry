@idb
Feature: Amqp accrual
  In order to preserve files from clients such as IDB
  As a client application
  I want to be able to tell Medusa to ingest a file and have it go to preservation storage

  Background:
    Given there is an IDB file group

  Scenario: Medusa receives message from IDB and creates delayed job to ingest
    When IDB sends an ingest request
    And Medusa picks up the IDB AMQP request
    Then there should be an IDB ingest delayed job reflecting the ingest request

  Scenario: Medusa receives message from IDB and creates delayed job to ingest, using new message syntax
    When IDB sends an ingest request with new message syntax
    And Medusa picks up the IDB AMQP request
    Then there should be an IDB ingest delayed job reflecting the ingest request with new message syntax

  Scenario: Medusa runs delayed job for IDB ingest, ingesting file and returning message to IDB
    When there is an IDB ingest delayed job
    And the IDB ingest delayed job is run
    Then the IDB file named 'file.txt' should be present in medusa storage
    And Medusa should have sent an ingest return message to IDB

  Scenario: Medusa runs delayed job for IDB ingest with new message syntax, ingesting file and returning message to IDB
    When there is an IDB ingest delayed job with new message syntax
    And the IDB ingest delayed job is run
    Then the IDB file named 'content.txt' should be present in medusa storage
    And Medusa should have sent an ingest return message to IDB with new message syntax
