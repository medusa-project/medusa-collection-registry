Feature: Title uniqueness
  In order to track certain objects in an orderly fashion
  As a librarian
  I want duplicate titles to be forbidden

  Background:
    Given I am logged in
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the repository titled 'Plants' has collections with fields:
      | title |
      | Roses |
    And I have production_units with fields:
      | title    |
      | Scanning |

  Scenario: Prevent duplicate repository titles
    Given I go to the repository creation page
    And PENDING

  Scenario: Prevent duplicate production unit titles
    Given PENDING

  Scenario: Prevent duplicate collection titles under same repository
    Given PENDING

  Scenario: Allow duplicate collection titles under different repositories
    Given PENDING