Feature: JSON data about file group
  In order to expose file group data to other applications
  As the system
  I want to be able to export JSON describing a file_group

  Background:
    Given the collection with title 'Dogs' has child file groups with fields:
      | external_file_location | name        | id | type              | cfs_directory_id |
      | Grainger               | Engineering | 1  | BitLevelFileGroup | 20               |
    And every cfs directory with fields exists:
      | id |path|
      | 20 | dir/path   |

  Scenario: Fetch JSON for a file group for basic auth user
    Given I provide basic authentication
    And The file group with location 'Grainger' has file type 'Master Metadata'
    When I request JSON for the file group with location 'Grainger'
    Then the JSON should have "id"
    And the JSON should have "collection_id"
    And the JSON at "external_file_location" should be "Grainger"
    And the JSON at "name" should be "Engineering"
    And the JSON at "type" should be "Master Metadata"
    And the JSON at "storage_level" should be "bit_level"
    And the JSON at "cfs_directory/id" should be 20
    And the JSON at "cfs_directory/path" should be "/cfs_directories/20.json"
    And the JSON at "cfs_directory/name" should be "dir/path"