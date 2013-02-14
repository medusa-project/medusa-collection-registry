Feature: Assessment Management
  In order to manage Assessments
  As a librarian
  I want to create and delete assessments for a collection

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has assessments with fields:
      | date       | preservation_risks | notes            | name|
      | 2012-01-09 | Old formats        | Pictures of dogs |  Assessing   |

  Scenario: View assessments of a collection
    When I view the collection titled 'Dogs'
    Then I should see an assessment table

  Scenario: Delete assessment from collection
    When I view the collection titled 'Dogs'
    And I click on 'Delete' in the assessments table
    Then I should be on the view page for the collection titled 'Dogs'
    And the collection titled 'Dogs' should have 0 assessments

  Scenario: Navigate to assessment
    When I view the collection titled 'Dogs'
    And I click on 'Assessing'
    Then I should be on the view page for the assessment with date '2012-01-09' for the collection titled 'Dogs'