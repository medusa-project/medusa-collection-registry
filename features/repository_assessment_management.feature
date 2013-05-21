Feature: Repository Assessment Management
  In order to assess the preservation characteristics of a repository
  As a librarian
  I want to create and delete assessments for a repository

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
    And the repository titled 'Animals' has an assessment named 'Evaluation'

  Scenario: View assessments of a repository
    When I view the repository titled 'Animals'
    Then I should see an assessment table

  Scenario: Delete assessment from a repository
    When I view the repository titled 'Animals'
    And I click on 'Delete' in the assessments table
    Then I should be on the view page for the repository titled 'Animals'
    And the repository titled 'Animals' should have 0 assessments

  Scenario: Navigate to an assessment
    When I view the repository titled 'Animals'
    And I click on 'Evaluation'
    Then I should be on the view page for the assessment named 'Evaluation'

  Scenario: Create a new assessment
    When I view the repository titled 'Animals'
    And I click on 'Add Assessment'
    Then I should be on the new assessment page

  Scenario: Navigate from an assessment back to repository
    When I view the assessment named 'Evaluation'
    And I click on 'Animals'
    Then I should be on the view page for the repository titled 'Animals'