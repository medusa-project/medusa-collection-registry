@current
Feature: File format notes and normalization paths
  In order to track information about file formats
  As a librarian
  I want to be able to add notes and normalization paths to file formats

  Background:
    Given the file format with name 'tiff' exists
    And the file format with name 'tiff' has child file format note with fields:
      | note         |
      | My tiff note |
    And the file format with name 'tiff' has child file format normalization path with fields:
      | name                 |
      | Normalization Path 1 |

  Scenario: See notes when viewing file format
    When I view the file format with name 'tiff'
    Then I should see 'My tiff note'
    And I should see 'Normalization Path 1'

  Scenario: Add note to file format
    When PENDING

  Scenario: Delete note from file format
    When PENDING

  Scenario: Edit note of file format
    When PENDING

  Scenario: Add normalization path to file format
    When PENDING

  Scenario: Delete normalization path from file format
    When PENDING

  Scenario: Edit normalization path of file format
    When PENDING