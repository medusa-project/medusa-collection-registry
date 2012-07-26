Feature: File Group description
  In order to track information about file groups
  As a librarian
  I want to edit file group information

  Background:
    Given I am logged in
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | file_location | file_format | total_file_size | total_files | last_access_date |
      | Main Library  | image/jpeg  | 100             | 1200        | 2012-05-15       |
      | Grainger      | text/xml    | 4               | 2400        | 2012-06-16       |

  Scenario: View a file group
    When I view the file group with file location 'Main Library' for the collection titled 'Dogs'
    Then I should see 'image/jpeg'
    And I should see '2012-05-15'
    And I should see '1200'

  Scenario: Edit a file group
    When I edit the file group with file location 'Main Library' for the collection titled 'Dogs'
    And I fill in fields:
      | field       | value |
      | total_files | 1300  |
    And I press 'Update File group'
    Then I should be on the view page for the file group with location 'Main Library' for the collection titled 'Dogs'
    And I should see '1300'
    And I should not see '1200'

  Scenario: Navigate from the file group view page to owning collection
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    And I click on 'Dogs'
    Then I should be on the view page for the collection titled 'Dogs'

  Scenario: Navigate from file group view page to its edit page
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    And I click on 'Edit'
    Then I should be on the edit page for the file group with location 'Main Library' for the collection titled 'Dogs'

  Scenario: Delete file group from view page
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    And I click on 'Delete'
    Then I should be on the view page for the collection titled 'Dogs'
    And The collection titled 'Dogs' should not have a file group with location 'Main Library'

  Scenario: Create a new file group
    When I view the collection titled 'Dogs'
    And I click on 'Add File Group'
    And I fill in fields:
      | field            | value      |
      | file_location    | Undergrad  |
      | file_format      | image/tiff |
      | total_file_size  | 22         |
      | total_files      | 333        |
    And I fill in file group form date '2012-07-17'
    And I press 'Create File group'
    Then I should be on the view page for the file group with location 'Undergrad' for the collection titled 'Dogs'
    And I should see 'Undergrad'
    And I should see 'image/tiff'
    And The collection titled 'Dogs' should have a file group with location 'Undergrad'
  

