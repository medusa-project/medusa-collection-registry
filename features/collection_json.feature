Feature: JSON data about collection
  In order to expose collection data to other applications
  As the system
  I want to be able to export JSON describing a collection

  Background:
    Given the collection titled 'Dogs' has file groups with fields:
      | file_location |
      | Grainger      |
      | Main Library  |

  Scenario: Fetch JSON for a collection
    When I request JSON for the collection titled 'Dogs'
    Then the JSON should have "id"
    And the JSON should have "uuid"
    And the JSON should have "root_directory_id"
    And the JSON at "title" should be "Dogs"
    And the JSON at "file_group_ids" should be an array
    And the JSON at "file_group_ids" should have 2 entries



