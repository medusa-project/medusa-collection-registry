Feature: JSON data about file group
  In order to expose file group data to other applications
  As the system
  I want to be able to export JSON describing a file_group

  Background:
    Given the collection titled 'Dogs' has file groups with fields:
      | external_file_location |
      | Grainger      |

  Scenario: Fetch JSON for a collection
    Given The file group with location 'Grainger' has file type 'Master Metadata'
    When I request JSON for the file group with location 'Grainger'
    Then the JSON should have "id"
    And the JSON should have "collection_id"
    And the JSON at "external_file_location" should be "Grainger"
    And the JSON at "type" should be "Master Metadata"
