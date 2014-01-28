Feature: Collection authorization
  In order to protect the attachments
  As the system
  I want to enforce proper authorization

  Background:
    Given the repository titled 'Sample Repo' has collections with fields:
      | title | start_date | end_date   | published | ongoing | description |
      | dogs  | 2010-01-01 | 2012-02-02 | true      | true    | Dog stuff   |

  Scenario: Enforce permissions
    Then deny object permission on the collection with title 'dogs' to users for action with redirection:
      | public user | view, edit, update, delete, events, red_flags | authentication |
      | visitor     | edit, update, delete        | unauthorized   |
      | manager     | delete        | unauthorized   |
    And deny permission on the collection collection to users for action with redirection:
      | public user | view_index, new, create | authentication |
      |visitor      |new, create              |unauthorized    |

  Scenario: View access system index for a collection as a public user
    Given The access system named 'DSpace' exists
    When I go to the access system index page
    And I click on 'DSpace'
    Then I should be on the login page

  Scenario: View public profile index for a collection as a public user
    Given the package profile named 'Profile' exists
    When I go to the package profile index page
    And I click on 'Profile'
    Then I should be on the login page
