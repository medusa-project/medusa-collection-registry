Feature: Assessment authorization
  In order to protect the assessments
  As the system
  I want to enforce proper authorization

  Background:
    Given the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has assessments with fields:
      | date       | name      |
      | 2012-01-09 | Once over |

  Scenario: Public user tries to view assessment
    Given I am not logged in
    When I view the assessment named 'Once over'
    Then I should be on the login page

  Scenario: Visitor tries to view assessment
    Given I am logged in as a visitor
    When I view the assessment named 'Once over'
    Then I should be on the view page for the assessment named 'Once over'

  Scenario: Public user tries to delete assessment
    Then trying to delete the assessment with name 'Once over' as a public user should redirect to authentication

  Scenario: Visitor tries to delete assessment
    Then trying to delete the assessment with name 'Once over' as a visitor should redirect to unauthorized

  Scenario: Manager tries to delete assessment
    Then trying to delete the assessment with name 'Once over' as a manager should redirect to unauthorized

  Scenario: Public user tries to edit assessment
    Then trying to edit the assessment with name 'Once over' as a public user should redirect to authentication

  Scenario: Visitor tries to edit assessment
    Then trying to edit the assessment with name 'Once over' as a visitor should redirect to unauthorized

  Scenario: Public user tries to update assessment
    Then trying to update the assessment with name 'Once over' as a public user should redirect to authentication

  Scenario: Visitor tries to update assessment
    Then trying to update the assessment with name 'Once over' as a visitor should redirect to unauthorized

  Scenario: Public user tries to start assessment
    Then trying to do new with the assessment collection as a public user should redirect to authentication

  Scenario: Visitor tries to start assessment
    Then a visitor is unauthorized to start an assessment for the collection titled 'Dogs'

  Scenario: Public user tries to create assessment
    Then trying to do create with the assessment collection as a public user should redirect to authentication

  Scenario: Visitor tries to create assessment
    Then a visitor is unauthorized to create an assessment for the collection titled 'Dogs'


