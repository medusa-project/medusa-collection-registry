Feature: Access system authorization
  In order to protect the access systems
  As the system
  I want to enforce proper authorization

  Background:
    Given The access system named 'ContentDM' exists

  Scenario: Enforce permissions
    Then deny object permission on the access system with name 'ContentDM' to users for action with redirection:
      | public user      | edit, update, delete | authentication |
      | visitor, manager | edit, update, delete | unauthorized   |
    And deny permission on the access system collection to users for action with redirection:
      | public user      | new, create | authentication |
      | visitor, manager | new, create | unauthorized   |

