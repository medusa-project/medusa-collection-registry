Feature: Cfs directory size
  In order to speed up queries
  As the system
  I want to maintain the size of each cfs directory tree in the database

  Background:
    Given there are cfs directories with fields:
      | path |
      | root |
    And there are cfs subdirectories of the cfs directory with path 'root' with fields:
      | path   |
      | subdir |
    And there are cfs files of the cfs directory with path 'root' with fields:
      | name      | size |
      | chihuahua | 10   |
      | pit bull  | 100  |
    And there are cfs files of the cfs directory with path 'subdir' with fields:
      | name      | size |
      | long_hair | 20   |

  Scenario: Sizes should have been computed
    Then the cfs directory for the path 'root' should have tree size 130 and count 3
    And the cfs directory for the path 'subdir' should have tree size 20 and count 1

  Scenario: Adding a file should change the tree sizes
    When there are cfs files of the cfs directory with path 'subdir' with fields:
      | name       | size |
      | short_hair | 30   |
    Then the cfs directory for the path 'root' should have tree size 160 and count 4
    And the cfs directory for the path 'subdir' should have tree size 50 and count 2

  Scenario: Updating a file should change the tree sizes
    When I update the cfs file with name 'long_hair' with fields:
      | size |
      | 15   |
    Then the cfs directory for the path 'root' should have tree size 125 and count 3
    And the cfs directory for the path 'subdir' should have tree size 15 and count 1

  Scenario: Deleting a file should change the tree sizes
    When I destroy the cfs file with name 'long_hair'
    Then the cfs directory for the path 'root' should have tree size 110 and count 2
    And the cfs directory for the path 'subdir' should have tree size 0 and count 0

  Scenario: Deleting a directory should change the tree sizes
    When I destroy the cfs directory with path 'subdir'
    Then the cfs directory for the path 'root' should have tree size 110 and count 2




