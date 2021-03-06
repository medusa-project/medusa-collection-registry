Feature: Events authorization
  In order to protect event creation
  As the system
  I want to enforce restrict it to repository and medusa admins

  Background:
    Given the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | title   |
      | images |

  Scenario: Public user tries to create event for file group
    Then a public user is unauthorized to create an event for the file group titled 'images'

  Scenario: user tries to create event for file group
    Then a user is unauthorized to create an event for the file group titled 'images'
