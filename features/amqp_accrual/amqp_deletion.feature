@idb @current
Feature: Amqp deletion
  In order to preserve files from clients such as IDB
  As a client application
  I want to be able to tell Medusa to delete a file when appropriate

  Background:
    Given there is an IDB file group

  Scenario: Medusa receives message from IDB and creates delayed job to delete
    When IDB sends an delete request
    And Medusa picks up the IDB AMQP request
    Then there should be an IDB delete delayed job reflecting the delete request

  Scenario: Medusa runs delayed job for valid IDB delete, deleting file and returning message to IDB
    Given there is a valid IDB delete delayed job
    When the IDB delete delayed job is run
    Then the IDB file should have been deleted
    And Medusa should have sent a valid delete return message to IDB

  @idb-no-deletions
  Scenario: Medusa receives a delete message from IDB, but is configured not to allow deletions
    When IDB sends an delete request
    And Medusa picks up the IDB AMQP request
    Then Medusa should have sent an error return message to IDB matching 'Deletion is not allowed'

  Scenario: Medusa runs delayed job for IDB delete, but the file is in the wrong file group
    Given there is an IDB delete delayed job for a cfs file in another file group
    When the IDB delete delayed job is run
    Then no IDB file should be deleted
    And Medusa should have sent an error return message to IDB matching 'File is not in the allowed file group'

  Scenario: Medusa runs delayed job for IDB delete, but the file object is not found
    Given there is an IDB delete delayed job for a cfs file that does not exist
    When the IDB delete delayed job is run
    Then no IDB file should be deleted
    And Medusa should have sent an error return message to IDB matching 'File not found'

  Scenario: Medusa runs delayed job for IDB delete, but the uuid corresponds to a non-file object
    Given there is an IDB delete delayed job for a uuid corresponding to a non-file object
    When the IDB delete delayed job is run
    Then no IDB file should be deleted
    And Medusa should have sent an error return message to IDB matching 'File not found'