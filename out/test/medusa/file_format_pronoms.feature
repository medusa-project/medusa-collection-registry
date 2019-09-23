@javascript
Feature: File Format Pronoms
  In order to use standard language for file formats
  As a librarian
  I want to be able manage pronoms associated with file formats

  Background:
    Given I am logged in as an admin
    And every file format with fields exists:
      | name | policy_summary             |
      | tiff | what we do with TIFF files |
    And the file format with name 'tiff' has child pronoms with fields:
      | pronom_id | version |
      | fmt/360   | 2.1     |

  Scenario: Edit Pronom
    When I view the file format with name 'tiff'
    And I click on 'Edit Pronom'
    And I fill in fields:
      | Pronom ID | x-fmt/387 |
      | Version   | 2.2       |
    And I click on 'Update'
    Then I should see 'x-fmt/387 (2.2)'
    And a pronom with version '2.2' should exist

  Scenario: Create Pronom
    When I view the file format with name 'tiff'
    And I click on 'Create Pronom'
    And I fill in fields:
      | Pronom ID | x-fmt/387 |
      | Version   | 2.2       |
    And I wait 1 second
    And I click on 'Create'
    Then I should see 'x-fmt/387 (2.2)'
    And a pronom with version '2.2' should exist

  Scenario: Delete Pronom
    When I view the file format with name 'tiff'
    And I click on 'Delete Pronom' expecting an alert 'Are you sure? This cannot be undone.'
    Then I should see none of:
      | 2.1 | fmt/360 |
    And there should be no pronom with version '2.1'

