Feature: Producers authorization
  In order to protect producers
  As the system
  I want to enforce proper authorization

  Background:
    Given every producer with fields exists:
      | title    | address_1      | address_2 | city   | state    | zip   | phone_number | email                | url                         | notes                                          |
      | Scanning | 100 Elm Street | Suite 10  | Urbana | Illinois | 61801 | 555-2345     | scanning@example.com | http://scanning.example.com | They scan stuff here. http://notes.example.com |

  Scenario: Enforce permissions on producer
    Then deny object permission on the producer with title 'Scanning' to users for action with redirection:
      | public user | edit, update, delete, view | authentication |
      | manager     | edit                 | unauthorized   |
    And deny permission on the producer collection to users for action with redirection:
      | public user      | new, create, view_index | authentication |
      | manager, visitor | new, create | unauthorized   |
