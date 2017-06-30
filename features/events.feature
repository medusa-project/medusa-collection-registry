@javascript @search
Feature: Record events
  In order to have an audit trail
  As a librarian
  I want to record import events that happen as we manage digital objects

  Background:
    And the file group with title 'dog-files' has an event with key 'fits_performed' performed by 'admin@example.com'

  Scenario: Navigate from file group to events for file group
    Given I am logged in as an admin
    When I view the file group with title 'dog-files'
    And I click on 'Events'
    And I click on 'View Events'
    Then I should be viewing events for the file group with title 'dog-files'
    And I should see the cascaded_events table
    And I should see all of:
      | FITS analysis performed | admin@example.com |

  Scenario: Navigate from file group to events for file group as a manager
    Given I am logged in as a manager
    When I view the file group with title 'dog-files'
    And I click on 'Events'
    And I click on 'View Events'
    Then I should be viewing events for the file group with title 'dog-files'

  Scenario: Navigate from file group to events for file group as a user
    Given I am logged in as a user
    When I view the file group with title 'dog-files'
    And I click on 'Events'
    And I click on 'View Events'
    Then I should be viewing events for the file group with title 'dog-files'
