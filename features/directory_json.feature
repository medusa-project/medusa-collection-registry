Feature: JSON data about directory
  In order to expose bit file data to other applications
  As the system
  I want to be able to export JSON describing a directory

  Background:
    Given I have a directory named 'animal-files'
    And the directory named 'animal-files' has a subdirectory named 'dog-files'
    And the directory named 'dog-files' has bit files with fields:
      | name    | size | content_type | dx_ingested | md5sum                   | dx_name                                |
      | dog1.jpg | 9208 | image/jpeg   | true     | G7jiO82hrgstPNSD2t00Hw== | 0cdf6b50-2d1e-0130-bc56-000c2967d45f-9 |

    Scenario: Get JSON for a directory
      When I request JSON for the directory named 'dog-files'
      Then the JSON should have "id"
      And the JSON should have "parent_directory_id"
      And the JSON should have "root_directory_id"
      And the JSON should have "collection_id"
      And the JSON at "name" should be "dog-files"
      And the JSON at "path" should be "/dog-files"
      And the JSON at "subdirectory_ids" should have 0 entries
      And the JSON should not have "file_ids"
      And the JSON at "files" should have 1 entry

    Scenario: Get JSON for directory without file information
      When I request JSON for the directory named 'dog-files' without file information
      Then the JSON should not have "files"
      And the JSON at "file_ids" should have 1 entry

    Scenario: Get JSON for directory without subdirectory information
      When I request JSON for the directory named 'dog-files' without subdirectory information
      Then the JSON should not have "subdirectory_ids"