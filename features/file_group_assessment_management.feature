Feature: File Group Assessment Management
  In order to assess the preservation characteristics of a file group
  As a librarian
  I want to create and delete assessments for a file group

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | external_file_location | file_format | total_file_size | total_files |  summary      | provenance_note |
      | Main Library           | image/jpeg  | 100             | 1200        |  main summary | main provenance |
    And the file group with location 'Main Library' has assessments with fields:
      | date       | preservation_risks | notes                 | name|
      | 2013-02-11 | On CD              | Pictures of cute dogs |Assessing|

  Scenario: View assessments of a file group
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    Then I should see an assessment table

  Scenario: Delete assessment from a file group
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    And I click on 'Delete' in the assessments table
    Then I should be on the view page for the file group with location 'Main Library' for the collection titled 'Dogs'
    And the collection titled 'Dogs' should have 0 assessments

  Scenario: Navigate to an assessment
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    And I click on 'Assessing'
    Then I should be on the view page for the assessment with date '2013-02-11' for the file group with location 'Main Library'

  Scenario: Create a new assessment
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    And I click on 'Add Assessment'
    Then I should be on the new assessment page