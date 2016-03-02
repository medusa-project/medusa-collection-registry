Feature: Repositories authorization
  In order to protect the repositories
  As the system
  I want to enforce proper authorization

  Background:
    Given I have repositories with fields:
      | title    | notes      |
      | Sample 1 | Some notes |

  Scenario: Enforce permissions
    Then deny object permission on the repository with title 'Sample 1' to users for action with redirection:
      | public user | view, edit, update, red_flags, events | authentication |
      | user     | edit, update, delete                  | unauthorized   |
      | manager     | delete                                | unauthorized   |
    And deny permission on the repository collection to users for action with redirection:
      | public user      | view_index, new, create | authentication |
      | user, manager | new, create             | unauthorized   |


