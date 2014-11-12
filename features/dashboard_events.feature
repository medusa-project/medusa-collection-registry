Feature: Dashboard event list
  In order to view recent happenings in Medusa
  As a librarian
  I want the dashboard to have a list of recent events

  Background:
    Given I am logged in as an admin
    And the collection with title 'Animals' has child file groups with fields:
      | name | type              |
      | Dogs | BitLevelFileGroup |
    And the file group named 'Dogs' has events with fields:
      | note         |
      | Current Event |
    And the file group named 'Dogs' has events with fields:
      | note      | updated_at |
      | Old Event | 2010-01-01 |

  Scenario: Dashboard shows recent events, but not old ones
    When I go to the dashboard
    Then I should see 'Current Event'
    And I should not see 'Old Event'

  Scenario: Navigate from dashboard to complete events index
    When I go to the dashboard
    And I click on 'View all events'
    Then I should be on the events index page