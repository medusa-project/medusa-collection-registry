Feature: Package Profiles authorization
  In order to protect package profiles
  As the system
  I want to enforce proper authorization

  Background:
    Given every package profile with fields exists:
      | name | url                             | notes                          |
      | book | http://book_profile.example.com | Preservation package for books |

  Scenario: Enforce permissions
    Then deny object permission on the package profile with name 'book' to users for action with redirection:
      | public user      | view, edit, update, delete, collections | authentication |
      | manager, user | edit, update, delete                    | unauthorized   |
    And deny permission on the package profile collection to users for action with redirection:
      | public user      | new, create | authentication |
      | manager, user | new, create | unauthorized   |
