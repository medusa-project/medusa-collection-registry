Feature: File type
  In order to manage preservation
  As a librarian
  I want to be able to record the type (purpose) of files in a file group

  Background:
    Given I am logged in as an admin

  Scenario: Some values are provided by default
    Given Nothing
    Then There should be standard default file types

  Scenario: Select file type while editing file group and view results
    Given I am editing a file group
    When I select file type 'Derivative Metadata'
    And I press 'Update File group'
    Then I should see 'Derivative Metadata'
    And I should see 'File type'
