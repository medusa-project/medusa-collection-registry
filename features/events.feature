Feature: Record events
  In order to have an audit trail
  As a librarian
  I want to record import events that happen as we manage digital objects

  Background:
    And the file group named 'dog-files' has an event with key 'fits_performed' performed by 'admin@example.com'

  Scenario: Navigate from file group to events for file group
    Given I am logged in as an admin
    When I view the file group with name 'dog-files'
    And I click on 'View events'
    Then I should be on the events page for the file group named 'dog-files'
    And I should see the events table
    And I should see all of:
      | FITS analysis performed | admin@example.com |

  Scenario: Navigate from file group to events for file group as a manager
    Given I am logged in as a manager
    When I view the file group with name 'dog-files'
    And I click on 'View events'
    Then I should be on the events page for the file group named 'dog-files'

  Scenario: Navigate from file group to events for file group as a visitor
    Given I am logged in as a visitor
    When I view the file group with name 'dog-files'
    And I click on 'View events'
    Then I should be on the events page for the file group named 'dog-files'
