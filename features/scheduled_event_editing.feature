Feature:
  As a preservation manager
  In order to change date and people assigned to scheduled events or remove them
  I want to be able to edit and delete scheduled events

  Background:
    Given I am logged in as an admin
    And the collection titled 'Dogs' has file groups with fields:
      | name | type              |
      | Toys | BitLevelFileGroup |
    And the file group named 'Toys' has scheduled events with fields:
      | key             | actor_netid | action_date | state     |
      | external_to_bit | Buster@example.com      | 2012-02-02  | scheduled |

  Scenario: Navigate from scheduled event list to edit event
    When I view events for the file group named 'Toys'
    And I click on 'edit' in the scheduled events table
    Then I should on the edit page for the scheduled event with key 'external_to_bit' and action date '2012-02-02'

  Scenario: Edit and update scheduled event from file group
    When I view events for the file group named 'Toys'
    And I click on 'edit' in the scheduled events table
    And I fill in fields:
      | Actor | Ruthie@example.com |
    And I click on 'Update Scheduled event'
    Then I should see 'Ruthie@example.com'
    And I should not see 'Buster@example.com'
    And I should be viewing events for the file group named 'Toys'

  Scenario: Edit and update scheduled event from collection
    When I view events for the collection titled 'Dogs'
    And I click on 'edit' in the scheduled events table
    And I fill in fields:
      | Actor | Ruthie@example.com |
    And I click on 'Update Scheduled event'
    Then I should see 'Ruthie@example.com'
    And I should not see 'Buster@example.com'
    And I should be viewing events for the collection titled 'Dogs'

  Scenario: Delete scheduled event from event list
    When I view events for the file group named 'Toys'
    And I click on 'delete' in the scheduled events table
    Then there should be no scheduled event with key 'external_to_bit' and action date '2012-02-02'
    And I should be viewing events for the file group named 'Toys'

  Scenario: Edit from and return to dashboard - should remember where the editing process kicked off
    When I go to the dashboard
    And I click on 'edit' in the scheduled events table
    And I click on 'Update Scheduled event'
    Then I should be on the dashboard page

