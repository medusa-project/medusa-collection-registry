Feature: JSON data about a cfs directory
  In order to expose cfs directory data to other applications
  As the system
  I want to be able to export JSON describing a cfs directory

  Background:
    Given the collection with title 'Dogs' has child file groups with fields:
      | external_file_location | title       | id | type              |
      | Grainger               | Engineering | 1  | BitLevelFileGroup |
    And every cfs directory with fields exists:
      | id | path     | parent_id | root_cfs_directory_id | parent_type  |
      | 20 | dir/path | 1         | 20                    | FileGroup    |
      | 40 | target   | 20        | 20                    | CfsDirectory |
      | 60 | child_1  | 40        | 20                    | CfsDirectory |
      | 80 | child_2  | 40        | 20                    | CfsDirectory |
    And there are cfs files with fields:
      | id  | name        | cfs_directory_id | md5_sum                          | content_type_name | size  | mtime                |
      | 100 | file.txt    | 40               |                                  |                   |       |                      |
      | 200 | picture.jpg | 40               | 33c25385888a2203c09493224fffda27 | image/jpeg        | 12345 | 2014-04-23T15:38:43Z |
      | 300 | sound.aiff  | 40               |                                  |                   |       |                      |

  Scenario: Fetch JSON for a cfs directory for basic auth user
    Given I provide basic authentication
    When I view JSON for the cfs directory with id '40'
    Then the JSON at "id" should be 40
    And the JSON at "name" should be "target"
    And the JSON at "subdirectories" should be an array
    And the JSON at "subdirectories" should have 2 entries
    And the JSON at "subdirectories/0/id" should be 60
    And the JSON at "subdirectories/0/name" should be "child_1"
    And the JSON at "subdirectories/0/path" should be "/cfs_directories/60.json"
    And the JSON at "files" should be an array
    And the JSON at "files" should have 3 entries
    And the JSON at "files/0/id" should be 100
    And the JSON at "files/0/name" should be "file.txt"
    And the JSON at "files/0/path" should be "/cfs_files/100.json"
    And the JSON at "parent_directory/id" should be 20
    And the JSON at "parent_directory/name" should be "dir/path"
    And the JSON at "parent_directory/path" should be "/cfs_directories/20.json"

  Scenario: Fetch JSON for a cfs file for basic auth user
    Given I provide basic authentication
    When I view JSON for the cfs file with id '200'
    Then the JSON at "id" should be 200
    And the JSON at "name" should be "picture.jpg"
    And the JSON at "md5_sum" should be "33c25385888a2203c09493224fffda27"
    And the JSON at "content_type" should be "image/jpeg"
    And the JSON at "size" should be 12345
    And the JSON at "mtime" should be "2014-04-23T15:38:43Z"
    And the JSON at "directory/id" should be 40
    And the JSON at "directory/name" should be "target"
    And the JSON at "directory/path" should be "/cfs_directories/40.json"
