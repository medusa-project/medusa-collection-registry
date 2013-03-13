Feature: Record events
  In order to have an audit trail
  As a librarian
  I want to record import events that happen as we manage digital objects

  Background:
    Given I am logged in as an admin
    And the file group named 'dog-files' has an event with key 'fits_performed' performed by 'admin'

  Scenario: Navigate from file group to events for file group
    When I view the file group named 'dog-files'
    And I click on 'View events'
    Then I should be on the events page for the file group named 'dog-files'
    And I should see the events table
    And I should see all of:
      | FITS analysis performed | admin |