Feature: Storage media
  In order to organize preservation
  As a librarian
  I want to track media used to store various file groups

  Background:
    Given I am logged in as an admin

  Scenario: Some values are provided by default
    Then There should be standard default storage media

  Scenario: Select storage medium while editing file group and view results
    Given I am editing a file group
    When I select storage medium 'file server'
    And I press 'Update File group'
    Then I should see 'file server'
    And I should see 'Storage Medium'
