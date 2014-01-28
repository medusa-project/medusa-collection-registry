Feature: Events authorization
  In order to protect event creation
  As the system
  I want to enforce restrict it to repository and medusa admins

  Background:
    Given the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | name   |
      | images |

  Scenario: Public user tries to create event for file group
    Then a public user is unauthorized to create an event for the file group named 'images'

  Scenario: Visitor tries to create event for file group
    Then a visitor is unauthorized to create an event for the file group named 'images'