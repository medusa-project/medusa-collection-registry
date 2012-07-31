Feature: File type
  In order to manage preservation
  As a librarian
  I want to be able to record the content type of a collection

  Background:
    Given I am logged in

  Scenario: Some values are provided by default
    Given Nothing
    Then There should be standard default content types

  Scenario: Select content type while editing collection and view results
    Given I am editing a collection
    When I select content type 'research data'
    And I press 'Update Collection'
    Then I should see 'research data'
    And I should see 'Content Type'