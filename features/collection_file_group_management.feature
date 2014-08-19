Feature: File Group Management
  In order to manage File Groups connected with a collection
  As a librarian
  I want to operate on file groups from the collection view

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | external_file_location | file_format | total_file_size | total_files | name   | type              |
      | Main Library           | image/jpeg  | 100             | 1200        | images | ExternalFileGroup |

  Scenario: View file groups of a collection
    When I view the collection with title 'Dogs'
    Then I should see the file group collection table
    And I should see all of:
      | images | 1,200 |

  Scenario: Navigate to file group
    When I view the collection with title 'Dogs'
    And I click on 'images' in the file groups table
    Then I should be on the view page for the file group with name 'images'

  Scenario: See id of file group in table
    When I view the collection with title 'Dogs'
    Then I should see the file group id for the file group with location 'Main Library' in the file group collection table

  Scenario: View file group events
    When I view the collection with title 'Dogs'
    And I click on 'View All' in the event actions
    Then I should be viewing events for the file group with name 'images'

  Scenario: Add file group event
    When I view the collection with title 'Dogs'
    And I click on 'Add New' in the event actions
    And I submit the new event form on the collection view page
    Then the file group named 'images' should have 1 events

  Scenario: View file group assessments
    When I view the collection with title 'Dogs'
    And I click on 'View All' in the assessment actions
    Then I should be on the view page for the file group with name 'images'

  Scenario: Create new assessment
    When I view the collection with title 'Dogs'
    And I click on 'Add New' in the assessment actions
    Then I should be on the new assessment page

  Scenario: Create related file group
    When I view the collection with title 'Dogs'
    And I click on 'Add New' in the related-file-group actions
    Then I should be on the edit page for the file group with name 'images'

  Scenario: See related file group
    Given the collection titled 'Dogs' has file groups with fields:
      | name | type              |
      | text | BitLevelFileGroup |
    And the file group named 'images' has relation note 'text created from images' for the target file group 'text'
    When I view the collection with title 'Dogs'
    Then I should see all of:
      | Ingested from | Ingested to |

  Scenario: Navigate to files of a bit level file group
    Given the collection titled 'Dogs' has file groups with fields:
      | name | type              |
      | bit  | BitLevelFileGroup |
    And there is a physical cfs directory 'bit/path'
    And the file group named 'bit' has cfs root 'bit/path'
    When I view the collection with title 'Dogs'
    And I click on 'View files'
    Then I should be viewing the cfs root directory for the file group named 'bit'
    #Then I should be viewing the cfs directory 'bit/path'

  Scenario: See the package profile of a file group in the file groups table
    Given the file group named 'images' has package profile named 'image_package'
    When I view the collection with title 'Dogs'
    Then I should see 'image_package'

  Scenario: Navigate to package profile of owned file group
    Given the file group named 'images' has package profile named 'image_package'
    When I view the collection with title 'Dogs'
    And I click on 'image_package'
    Then I should be on the view page for the package profile with name 'image_package'

