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
      | name      | content_type_name |
      | chihuahua | image/jpeg        |
      | pit bull  | application/xml   |
    And there are cfs files of the cfs directory with path 'subdir' with fields:
      | name      | content_type_name |
      | long_hair | image/jpeg        |

  @javascript
  Scenario: Navigate from dashboard to view of cfs files with a given type
    Given I am logged in as an admin
    When I go to the dashboard
    And I click on 'File Statistics'
    And I click on 'image/jpeg'
    Then I should be on the cfs files page for the content type with name 'image/jpeg'
    And I should see a table of cfs files with 2 rows
    And I should see all of:
      | chihuahua | long_hair |
    And I should see none of:
      | pit bull |

  Scenario: Public user cannot view cfs files via content type
    Then deny object permission on the content type with name 'image/jpeg' to users for action with redirection:
      | public user | cfs_files | authentication |

  #This test is clearly not perfect, but should fail at least 1 in 3 times if there is a problem
  @javascript
  Scenario: View a random file of a given extension
    Given I am logged in as an admin
    When I go to the dashboard
    And I click on 'File Statistics'
    And I click on 'image/jpeg'
    And I click on 'Random File'
    Then I should see none of:
      | pit bull |