Feature: Access system authorization
  In order to protect the access systems
  As the system
  I want to enforce proper authorization

  Background:
    Given the access system with name 'ContentDM' exists

  Scenario: Enforce permissions
    Then deny object permission on the access system with name 'ContentDM' to users for action with redirection:
      | public user      | edit, update, delete, collections | authentication |
      | visitor, manager | edit, update, delete | unauthorized   |
    And deny permission on the access system collection to users for action with redirection:
      | public user      | new, create | authentication |
      | visitor, manager | new, create | unauthorized   |

