Feature: Production Units for File Groups
  In order to know the origin of files
  As a librarian
  I want file groups to track their production unit

  Background:
    Given I have production_units with fields:
      | title    |
      | Scanning |
      | Scraping |
    And the collection titled 'Dogs' has file groups with fields:
      | file_location |
      | Grainger |

  Scenario:
    When I edit the file group with location 'Grainger' for the collection titled 'Dogs'
    And I select the production unit 'Scanning'
    And I press 'Update File group'
    Then I should see 'Scanning'
    And I should see 'Production unit'
    And The file group with location 'Grainger' for the collection titled 'Dogs' should have production unit titled 'Scanning'

  Scenario:
    Given The file group with location 'Grainger' for the collection titled 'Dogs' has production unit titled 'Scanning'
    When I view the file group with location 'Grainger' for the collection titled 'Dogs'
    And I click on 'Scanning'
    Then I should be on the view page for the production unit titled 'Scanning'