Feature: Producer collection table
  In order to manage preservation
  As a librarian
  I want to be able to see what collections a producer has worked on

  Background:
    Given I am logged in as an admin
    And I have producers with fields:
      | title    |
      | Scanning |
    And the repository with title 'Animals' has child collections with fields:
      | title | external_id      |
      | Dogs  | dog_external_id  |
      | Cats  |                  |
      | Bears | bear_external_id |
    And The collection titled 'Dogs' has 2 file groups produced by 'Scanning'
    And The collection titled 'Cats' has 1 file group produced by 'Scanning'

  Scenario: Collection table should exist
    When I view the producer with title 'Scanning'
    Then I should see a table of collections

  Scenario: Collection table should be correct
    When I view the producer with title 'Scanning'
    Then I should see all of:
      | Dogs | Cats | dog_external_id |
    And I should see none of:
      | Bears | bear_external_id |
    And The table of collections should have 2 rows

  Scenario: Collection table should link repository owning each collection
    When I view the producer with title 'Scanning'
    And I click on 'Animals'
    Then I should be on the view page for the repository with title 'Animals'
