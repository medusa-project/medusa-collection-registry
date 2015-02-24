Feature: Scheduled event authorization
  In order to protect the scheduled events
  As the system
  I want to enforce proper authorization

  Background:
    Given the collection with title 'Dogs' has child file groups with fields:
      | title | type              |
      | Toys | BitLevelFileGroup |
    And the file group with title 'Toys' has scheduled events with fields:
      | key             | actor_email | action_date | state     |
      | external_to_bit | buster@example.com      | 2012-02-02  | scheduled |

  Scenario: Enforce permissions
    Then deny object permission on the scheduled event with key 'external_to_bit' to users for action with redirection:
      | public user      | edit, update, create, destroy, cancel(post), complete(post) | authentication |
      | visitor, manager | edit, update, create, destroy, cancel(post), complete(post) | unauthorized   |