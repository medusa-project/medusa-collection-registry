Feature: Assessment authorization
  In order to protect the assessments
  As the system
  I want to enforce proper authorization

  Background:
    Given the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the assessable collection with title 'Dogs' has assessments with fields:
      | date       | name      |
      | 2012-01-09 | Once over |

  Scenario: Enforce permissions
    Then deny object permission on the assessment with name 'Once over' to users for action with redirection:
      | public user | view, delete, edit, update | authentication |
      | visitor     | delete, edit, update        | unauthorized   |
      | manager     | delete                     | unauthorized   |
    And deny permission on the assessment collection to users for action with redirection:
      | public user | new, create | authentication |

  Scenario: Visitor tries to start assessment
    Then a visitor is unauthorized to start an assessment for the collection titled 'Dogs'

  Scenario: Visitor tries to create assessment
    Then a visitor is unauthorized to create an assessment for the collection titled 'Dogs'


