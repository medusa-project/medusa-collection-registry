Feature: Production unit collection table
  In order to manage preservation
  As a librarian
  I want to be able to see what collections a production unit has worked on

  Background:
    Given I am logged in as an admin
    And I have production_units with fields:
      | title    |
      | Scanning |
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
      | Cats  |
      | Bears |
    And The collection titled 'Dogs' has 2 file groups produced by 'Scanning'
    And The collection titled 'Cats' has 1 file group produced by 'Scanning'

  Scenario: Collection table should exist
    When I view the production unit titled 'Scanning'
    Then I should see a table of collections

  Scenario: Collection table should be correct
    When I view the production unit titled 'Scanning'
    Then I should see all of:
      | Dogs | Cats |
    And I should not see 'Bears'
    And The table of collections should have 2 rows