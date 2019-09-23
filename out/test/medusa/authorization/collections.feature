Feature: Collection authorization
  In order to protect the attachments
  As the system
  I want to enforce proper authorization

  Background:
    Given the repository with title 'Sample Repo' has child collections with fields:
      | title | description |
      | dogs  | Dog stuff   |

  Scenario: Enforce permissions
    Then deny object permission on the collection with title 'dogs' to users for action with redirection:
      | public user | view, edit, update, delete, events, red_flags, assessments, attachments | authentication |
      | user        | edit, update, delete                                                    | unauthorized   |
      | manager     | delete                                                                  | unauthorized   |
    And deny permission on the collection collection to users for action with redirection:
      | public user | view_index, new, create | authentication |
#      | user        | new, create             | unauthorized   |
      | user        | create                  | unauthorized   |
      | user        | new                     | unauthorized   |

  Scenario: View access system index for a collection as a public user
    Given the access system with name 'DSpace' exists
    When I go to the access system index page
    And I click on 'DSpace'
    Then I should be on the login page

