Feature: Repository Assessment Management
  In order to assess the preservation characteristics of a repository
  As a librarian
  I want to create and delete assessments for a repository

  Background:
    Given I am logged in as an admin
    And the repository with title 'Animals' has child collections with fields:
      | title |
    And the assessable repository with title 'Animals' has assessments with fields:
      | name       |
      | Evaluation |

  Scenario: View assessments of a repository
    When I view the repository with title 'Animals'
    Then I should see an assessment table

  Scenario: Navigate to an assessment
    When I view the repository with title 'Animals'
    And I click on 'Evaluation'
    Then I should be on the view page for the assessment with name 'Evaluation'

  Scenario: Create a new assessment
    When I view the repository with title 'Animals'
    And I click on 'Add Assessment'
    Then I should be on the new assessment page

  Scenario: Navigate from an assessment back to repository
    When I view the assessment with name 'Evaluation'
    And I click on 'Animals'
    Then I should be on the view page for the repository with title 'Animals'