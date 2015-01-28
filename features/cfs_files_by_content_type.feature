Feature: Cfs files by content type
  In order to support preservation for certain content types
  As a librarian
  I want to be able to view files of a certain content type

  Background:
    Given there are cfs directories with fields:
      | path |
      | root |
    And there are cfs subdirectories of the cfs directory with path 'root' with fields:
      | path   |
      | subdir |
    And there are cfs files of the cfs directory with path 'root' with fields:
      | name      | content_type_name    |
      | chihuahua | image/jpeg      |
      | pit bull  | application/xml |
    And there are cfs files of the cfs directory with path 'subdir' with fields:
      | name      | content_type_name |
      | long_hair | image/jpeg   |

  Scenario: Navigate from dashboard to view of cfs files with a given type
    Given I am logged in as an admin
    When I go to the dashboard
    And I click on 'image/jpeg'
    Then I should be on the cfs files page for the content type with name 'image/jpeg'
    And I should see a table of cfs files with 2 rows
    And I should see all of:
      | chihuahua | long_hair |
    And I should see none of:
      | pit bull |

  Scenario: Public user cannot view cfs files via content type
    When I am not logged in
    And I view cfs files for the content type with name 'image/jpeg'
    Then I should be on the login page