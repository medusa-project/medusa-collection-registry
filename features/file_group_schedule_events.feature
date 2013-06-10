Feature: Schedule events for a file group
  In order to keep track of workflow
  As a librarian
  I want to be able to schedule events and have the system notify me about them

  Background:
    Given I am logged in as an admin
    And the collection titled 'Animals' has file groups with fields:
      | name |
      | Dogs |

  Scenario: I can schedule an event from the show view for a file group
    When I view the file group named 'Dogs'
    And I fill in fields for a scheduled event:
      | Note        | Dog deletion |
      | Actor       | joe          |
      | Action date | 2010-01-02   |
    And I select 'Delete external file group' from 'Scheduled event'
    And I click on 'Create Scheduled event'
    Then the file group named 'Dogs' should have a scheduled event with fields:
      | key             | actor_netid | action_date | note         | state     |
      | external_delete | joe         | 2010-01-02  | Dog deletion | scheduled |
    And I should be on the view page for the file group named 'Dogs'
    And 'joe@illinois.edu' should receive an email with subject 'Medusa scheduled event reminder'

  Scenario: View scheduled events for a file group
    Given the file group named 'Dogs' has scheduled events with fields:
      | key             | actor_netid | action_date | state     |
      | external_delete | pete        | 2011-09-08  | scheduled |
    When I view events for the file group named 'Dogs'
    Then I should see the scheduled events table
    And I should see all of:
      | Delete external file group | pete | 2011-09-08 | scheduled |