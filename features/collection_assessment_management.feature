Feature: Assessment Management
  In order to manage Assessments
  As a librarian
  I want to create and delete assessments for a collection

  Background:
    Given I am logged in as an admin
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the assessable collection with title 'Dogs' has assessments with fields:
      | date       | preservation_risks | notes            | name|
      | 2012-01-09 | Old formats        | Pictures of dogs |  Assessing   |

  Scenario: View assessments of a collection
    When I view the collection with title 'Dogs'
    Then I should see an assessment table

  Scenario: Navigate to assessment
    When I view the collection with title 'Dogs'
    And I click on 'Assessing'
    Then I should be on the view page for the assessment with date '2012-01-09'