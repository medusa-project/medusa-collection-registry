Feature: Assessment authorization
  In order to protect the assessments
  As the system
  I want to enforce proper authorization

  Background:
    Given the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the assessable collection with title 'Dogs' has assessments with fields:
      | date       | name      |
      | 2012-01-09 | Once over |

  Scenario: Enforce permissions
    Then deny object permission on the assessment with name 'Once over' to users for action with redirection:
      | public user | view, delete, edit, update | authentication |
      | user     | delete, edit, update        | unauthorized   |
      | manager     | delete                     | unauthorized   |
    And deny permission on the assessment collection to users for action with redirection:
      | public user | new, create | authentication |

  Scenario: user tries to start assessment
    Then a user is unauthorized to start an assessment for the collection titled 'Dogs'

  Scenario: user tries to create assessment
    Then a user is unauthorized to create an assessment for the collection titled 'Dogs'


