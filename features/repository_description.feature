Feature: Repository description
  In order to track information about repositories
  As a librarian
  I want to be able to create repositories and edit descriptive information about them

  Scenario: Create repository
    Given I am logged in
    When I go to the repository creation page
    And I fill in fields:
      |field|value|
      |Title|Sample Repo|
      |Url  |http://repo.example.com|
      |Notes|This is a sample repository for the test|
    And I press 'Create Repository'
    Then A repository with title 'Sample Repo' should exist
    And I should see 'This is a sample repository for the test'
    And I should see 'http://repo.example.com'