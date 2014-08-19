Feature: Collection authorization
  In order to protect the attachments
  As the system
  I want to enforce proper authorization

  Background:
    Given the repository with title 'Sample Repo' has child collections with fields:
      | title | published | ongoing | description |
      | dogs  | true      | true    | Dog stuff   |

  Scenario: Enforce permissions
    Then deny object permission on the collection with title 'dogs' to users for action with redirection:
      | public user | view, edit, update, delete, events, red_flags | authentication |
      | visitor     | edit, update, delete                          | unauthorized   |
      | manager     | delete                                        | unauthorized   |
    And deny permission on the collection collection to users for action with redirection:
      | public user | view_index, new, create | authentication |
      | visitor     | new, create             | unauthorized   |

  Scenario: View access system index for a collection as a public user
    Given the access system with name 'DSpace' exists
    When I go to the access system index page
    And I click on 'DSpace'
    Then I should be on the login page

  Scenario: View public profile index for a collection as a public user
    Given the package profile with name 'Profile' exists
    When I go to the package profile index page
    And I click on 'Profile'
    Then I should be on the login page
