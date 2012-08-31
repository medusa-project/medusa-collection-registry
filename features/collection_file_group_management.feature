Feature: File Group Management
  In order to manage File Groups connected with a collection
  As a librarian
  I want to create and delete File Groups for a collection

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | file_location | file_format | total_file_size | total_files | last_access_date |
      | Main Library  | image/jpeg  | 100             | 1200        | 2012-05-15       |
      | Grainger      | text/xml    | 4               | 2400        | 2012-06-16       |

  Scenario: View file groups of a collection
    When I view the collection titled 'Dogs'
    Then I should see the file group collection table

  Scenario: Delete file group from collection
    When I view the collection titled 'Dogs'
    And I click on 'Delete' in the file groups table
    Then I should be on the view page for the collection titled 'Dogs'
    And the collection titled 'Dogs' should have 1 file group

  Scenario: Navigate to file group
    When I view the collection titled 'Dogs'
    And I click on 'View' in the file groups table
    Then I should be on the view page for the file group with location 'Main Library' for the collection titled 'Dogs'

  Scenario: Edit file group from collection
    When I view the collection titled 'Dogs'
    And I click on 'Edit' in the file groups table
    Then I should be on the edit page for the file group with location 'Main Library' for the collection titled 'Dogs'
