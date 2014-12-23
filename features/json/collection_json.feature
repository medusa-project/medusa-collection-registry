Feature: JSON data about collection
  In order to expose collection data to other applications
  As the system
  I want to be able to export JSON describing a collection

  Background:
    Given the collection with title 'Dogs' has child file groups with fields:
      | external_file_location | title       | id | type              |
      | Grainger               | Engineering | 1  | BitLevelFileGroup |
      | Main Library           | Classical   | 2  | ExternalFileGroup |

  Scenario: Fetch JSON for a collection for basic auth user
    Given I provide basic authentication
    When I request JSON for the collection titled 'Dogs'
    Then the JSON should have "id"
    And the JSON should have "uuid"
    And the JSON at "title" should be "Dogs"
    And the JSON at "file_groups" should be an array
    And the JSON at "file_groups" should have 2 entries
    And the JSON at "file_groups/0/id" should be 1
    And the JSON at "file_groups/0/path" should be "/file_groups/1.json"
    And the JSON at "file_groups/0/title" should be "Engineering"
    And the JSON at "file_groups/0/storage_level" should be "bit_level"



