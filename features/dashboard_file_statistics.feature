Feature: File Statistics Summary on the Collection Registry Dashboard
  In order to view a summary of file statistics in the collection registry
  As a librarian
  I want to have a dashboard view that shows it

  Background:
    Given I am logged in as an admin
    And I clear the cfs root directory
    And the cfs directory 'animals/dogs' contains cfs fixture file 'grass.jpg'
    And the cfs directory 'animals/dogs/pictures' contains cfs fixture file 'grass.jpg'
    And the cfs directory 'animals/dogs' contains cfs fixture file 'fits.xml'
    And the collection with title 'Animals' has child file groups with fields:
      | title          | type              |
      | Cats          | ExternalFileGroup |
      | Dogs-external | ExternalFileGroup |
      | Dogs          | BitLevelFileGroup |
    And I set the cfs root of the file group titled 'Dogs' to 'animals/dogs' and delayed jobs are run

  Scenario: View file statistics section of dashboard
    When I go to the dashboard
    And I click on 'File Statistics'
    Then I should see the file stats by content type table
    And I should see the file stats by file extension table

  Scenario: View bit preservation summary content_type table
    When I go to the dashboard
    And I click on 'File Statistics'
    Then I should see all of:
      | image/jpeg      | 2 | 332 KB  |
      | application/xml | 1 | 2.89 KB |

  Scenario: View bit & object preservation summary table
    Given The bit level file group statistics cache is up to date
    When I go to the dashboard
    And I click on 'File Statistics'
    Then I should see the file stats by content type table
    And I should see the file stats by file extension table
    And I should see all of:
      | Total Bit Preservation Files: | 3 | Total Object Preservation Files: | 0 |
    And I should see all of:
      | Total Bit Preservation Size: | 335 KB | Total Object Preservation Size: | 0 Bytes |

