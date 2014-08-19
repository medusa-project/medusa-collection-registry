Feature: File group authorization
  In order to protect file groups
  As the system
  I want to enforce proper authorization

  Background:
    Given the repository with title 'Animals' has child collection with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | name   |
      | images |

  Scenario: Enforce permissions
    Then deny object permission on the file group with name 'images' to users for action with redirection:
      | public user | view, edit, update, events, red_flags, create_cfs_fits(post), create_virus_scan(post) | authentication |
      | visitor     | edit, update, create_cfs_fits(post), create_virus_scan(post)                          | unauthorized   |
    And deny permission on the file group collection to users for action with redirection:
      | public user | new, create | authentication |

  Scenario: Visitor tries to start a file group
    Then a visitor is unauthorized to start a file group for the collection titled 'Dogs'

  Scenario: Visitor tries to create a file group
    Then a visitor is unauthorized to create a file group for the collection titled 'Dogs'


