Feature: Production Units for File Groups
  In order to know the origin of files
  As a librarian
  I want file groups to track their production unit

  Background:
    Given I am logged in
    And I have production_units with fields:
      | title    |
      | Scanning |
      | Scraping |
    And the collection titled 'Dogs' has file groups with fields:
      | file_location |
      | Grainger |
    And The file group with location 'Grainger' for the collection titled 'Dogs' has production unit titled 'Scanning'

  Scenario: Edit and view the production unit of a file group
    When I edit the file group with location 'Grainger' for the collection titled 'Dogs'
    And I select the production unit 'Scraping'
    And I press 'Update File group'
    Then I should see 'Scraping'
    And I should see 'Production unit'
    And The file group with location 'Grainger' for the collection titled 'Dogs' should have production unit titled 'Scraping'

  Scenario: Navigate from a file group to its production unit
    When I view the file group with location 'Grainger' for the collection titled 'Dogs'
    And I click on 'Scanning'
    Then I should be on the view page for the production unit titled 'Scanning'

  Scenario: Deleting a production unit should fail if it has file groups
    When I view the production unit titled 'Scanning'
    And I press 'Delete Production Unit'
    Then I should be on the view page for the production unit titled 'Scanning'
    And I should see 'Production Units with associated file groups cannot be deleted.'


