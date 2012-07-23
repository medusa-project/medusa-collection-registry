Feature: Repository description
  In order to track information about repositories
  As a librarian
  I want to be able to create repositories and edit descriptive information about them

  Scenario: Create repository
    Given I am logged in
    When I go to the repository creation page
    And I enter creation information
    And I press Create
    Then a repository should be created