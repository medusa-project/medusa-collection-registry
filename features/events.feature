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
    Then I should be viewing events for the file group with title 'dog-files'
    And I should see the events table
    And I should see all of:
      | FITS analysis performed | admin@example.com |

  Scenario: Navigate from file group to events for file group as a manager
    Given I am logged in as a manager
    When I view the file group with title 'dog-files'
    And I click on 'Events'
    Then I should be viewing events for the file group with title 'dog-files'

  Scenario: Navigate from file group to events for file group as a visitor
    Given I am logged in as a visitor
    When I view the file group with title 'dog-files'
    And I click on 'Events'
    Then I should be viewing events for the file group with title 'dog-files'

  Scenario: Delete an event
    Given I am logged in as a manager
    When I view events for the file group with title 'dog-files'
    And I click on 'Delete' in the events table
    Then I should be viewing events for the file group with title 'dog-files'
    And the file group with title 'dog-files' should have 0 events
    And I should see none of:
      | admin@example.com |

  Scenario: Update an event
    Given I am logged in as a manager
    When I view events for the file group with title 'dog-files'
    And I click on 'Edit' in the events table
    And I fill in fields:
      | Note | Added note |
    And I click on 'Update'
    And I click on 'Events'
    Then I should be viewing events for the file group with title 'dog-files'
    And I should see all of:
      | FITS analysis performed | admin@example.com | Added note |
    And the file group with title 'dog-files' should have 1 event

