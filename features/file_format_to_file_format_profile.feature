Feature: File Format to File Format Profile association
  In order to manage multiple ways of looking at a file format
  As a librarian
  I want to be able to associate file format profiles to file formats

  Background:
    Given every file format with fields exists:
      | name | pronom_id | policy_summary                  |
      | tiff | fmt/353   | what we do with TIFF files      |
      | jp2  | fmt/392   | what we do with JPEG 2000 files |
    And each file format profile with name exists:
      | TIFF1 | TIFF2 | JPEG |

  Scenario: Manage file format profiles for file format from file format edit page
    Given I am logged in as an admin
    When I edit the file format with name 'tiff'
    And I check 'TIFF1'
    And I check 'TIFF2'
    And I click on 'Update'
    Then I should be on the view page for the file format with name 'tiff'
    And I should see all of:
      | TIFF1 | TIFF2 |
    And I should not see 'JPEG'

  Scenario: Mangage file format for file format profile from file format profile edit page
    Given I am logged in as an admin
    When I edit the file format profile with name 'JPEG'
    And I select 'jp2' from 'File format'
    And I click on 'Update'
    Then I should see 'JPEG'
