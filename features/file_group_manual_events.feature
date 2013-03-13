Feature: Add events manually to a file group
  In order to have an audit trail for externally performed actions
  As a librarian
  I want to record import events that happen outside this system as we manage digital objects

  Background:
    Given I am logged in as an admin
    And the collection titled 'Animals' has file groups with fields:
      | name |
      | dogs |

  Scenario: I can add an event from the show view for a file group
    When I view the file group named 'dogs'
    And I fill in fields:
      | Note | Dog discussion |
    And I select 'External file group staged' from 'Event'
    And I click on 'Create Event'
    Then the file group named 'dogs' should have an event with key 'external_staged' performed by 'admin'
    And I should be on the view page for the file group named 'dogs
