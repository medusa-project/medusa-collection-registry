Feature: File Group Assessment Management
  In order to assess the preservation characteristics of a file group
  As a librarian
  I want to create and delete assessments for a file group

  Background:
    Given I am logged in as an admin
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | external_file_location | file_format | total_file_size | total_files | description      | provenance_note | title   |
      | Main Library           | image/jpeg  | 100             | 1200        | main summary | main provenance | Images |
    And the assessable file group with title 'Images' has assessments with fields:
      | date       | preservation_risks | notes                 | name      |
      | 2013-02-11 | On CD              | Pictures of cute dogs | Assessing |

  Scenario: View assessments of a file group
    When I view the file group with title 'Images'
    Then I should see an assessment table

  Scenario: Navigate to an assessment
    When I view the file group with title 'Images'
    And I click on 'Assessing'
    Then I should be on the view page for the assessment with date '2013-02-11'

  Scenario: Create a new assessment
    When I view the file group with title 'Images'
    And I click on 'Add Assessment'
    Then I should be on the new assessment page

  Scenario: Navigate from an assessment back to file group
    When I view the assessment with name 'Assessing'
    And I click on 'Images'
    Then I should be on the view page for the file group with title 'Images'