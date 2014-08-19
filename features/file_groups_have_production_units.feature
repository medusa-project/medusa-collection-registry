Feature: producers for File Groups
  In order to know the origin of files
  As a librarian
  I want file groups to track their producer

  Background:
    Given I am logged in as an admin
    And I have producers with fields:
      | title    |
      | Scanning |
      | Scraping |
    And the collection with title 'Dogs' has child file groups with fields:
      | name     | external_file_location |
      | grainger | Grainger               |
    And The file group with location 'Grainger' for the collection titled 'Dogs' has producer titled 'Scanning'

  Scenario: Edit and view the producer of a file group
    When I edit the file group with name 'grainger'
    And I select 'Scraping' from 'Producer'
    And I press 'Update File group'
    Then I should see 'Scraping'
    And I should see 'Producer'
    And The file group with location 'Grainger' for the collection titled 'Dogs' should have producer titled 'Scraping'

  Scenario: Navigate from a file group to its producer
    When I view the file group with name 'grainger'
    And I click on 'Scanning'
    Then I should be on the view page for the producer with title 'Scanning'

  Scenario: Deleting a producer should fail if it has file groups
    When I view the producer with title 'Scanning'
    And I click on 'Delete Producer'
    Then I should be on the view page for the producer with title 'Scanning'
    And I should see 'Producers with associated file groups cannot be deleted.'


