Feature: File Group Management
  In order to manage File Groups connected with a collection
  As a librarian
  I want to operate on file groups from the collection view

  Background:
    Given I am logged in as an admin
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | external_file_location | total_file_size | total_files | title  | type              | created_at |
      | Main Library           | 100             | 1200        | images | ExternalFileGroup | 2016-09-20 |

  Scenario: View file groups of a collection
    When I view the collection with title 'Dogs'
    Then I should see the file groups table
    And I should see all of:
      | images | 1,200 | 2016-09-20 |

  Scenario: Navigate to file group
    When I view the collection with title 'Dogs'
    And I click on 'images' in the file groups table
    Then I should be on the view page for the file group with title 'images'

  Scenario: See id of file group in table
    When I view the collection with title 'Dogs'
    Then I should see the file group id for the file group with location 'Main Library' in the file group collection table

  Scenario: View file group events
    When I view the collection with title 'Dogs'
    And I click on 'View' in the event actions
    Then I should be viewing events for the file group with title 'images'

  @javascript
  Scenario: Add file group event
    When I view the collection with title 'Dogs'
    And I click on 'Actions'
    And I click on 'Add' in the event actions
    And I wait 2 seconds
    And I click on 'Create Event'
    And I wait 1 second
    Then the file group with title 'images' should have 1 events

  Scenario: View file group assessments
    When I view the collection with title 'Dogs'
    And I click on 'View' in the assessment actions
    Then I should be viewing assessments for the file group with title 'images'

  Scenario: Create new assessment
    When I view the collection with title 'Dogs'
    And I click on 'Add' in the assessment actions
    Then I should be on the new assessment page

  Scenario: Create related file group
    When I view the collection with title 'Dogs'
    And I click on 'Add' in the related-file-group actions
    Then I should be on the edit page for the file group with title 'images'

  Scenario: See related file group
    Given the collection with title 'Dogs' has child file groups with fields:
      | title | type              |
      | text  | BitLevelFileGroup |
    And the file group titled 'images' has relation note 'text created from images' for the target file group 'text'
    When I view the collection with title 'Dogs'
    Then I should see all of:
      | Ingested from | Ingested to |


