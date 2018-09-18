@javascript
Feature: Collection file statistics
  In order to reason about the contents of a collection
  As a librarian
  I want to be able to view content type and file extension statistics for a collection

  Background:
    Given I am logged in as an admin
    And the main storage directory key 'animals/dogs' contains cfs fixture content 'grass.jpg'
    And the main storage directory key 'animals/dogs/pictures' contains cfs fixture content 'grass.jpg'
    And the main storage directory key 'animals/dogs' contains cfs fixture content 'fits.xml'
    And the collection with title 'Animals' has child file groups with fields:
      | title         | type              |
      | Cats          | ExternalFileGroup |
      | Dogs-external | ExternalFileGroup |
      | Dogs          | BitLevelFileGroup |
    And I set the cfs root of the file group titled 'Dogs' to 'animals/dogs' and delayed jobs are run


  Scenario: View file statistics section of collection
    When I refresh file stat caches
    And I view the collection with title 'Animals'
    Then I should see the file stats by content type table
    And I should see the file stats by file extension table
    And I should see all of:
      | image/jpeg      | 2 | 332 KB  |
      | application/xml | 1 | 2.89 KB |

    #need to figure out how to do this without poltergeist
  Scenario: Get CSV version of file statistics for collection
    When PENDING
    When I view the collection with title 'Animals'
    And within '#file-statistics' I click on 'CSV'
    Then I should receive a file 'file-statistics.csv' of type 'text/csv'