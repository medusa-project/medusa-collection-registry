Feature: File Formats Logical Extensions
  In order to manage potentially unruly real world file extensions
  As a librarian
  I want to be able to associate logical extensions with file formats

  Background:
    Given every file format with fields exists:
      | name | policy_summary             |
      | tiff | what we do with TIFF files |

  @javascript
  Scenario: Edit file format logical extensions, both initially setting and clearing
    Given I am logged in as an admin
    When I view the file format with name 'tiff'
    And I click consecutively on:
      | Edit | Select Logical Extension |
    And I fill in fields:
      | Logical extensions | perl, pl (Perl) |
    And I click consecutively on:
      | Close | Update |
    Then the logical extensions with fields should exist:
      | extension | description |
      | perl      |             |
      | pl        | Perl        |
    And the file format with name 'tiff' should have 2 logical extensions
    And I should see all of:
      | perl | pl (Perl) |
    When I view the file format with name 'tiff'
    And I click consecutively on:
      | Edit | Select Logical Extension |
    And I fill in fields:
      | Logical extensions | |
    And I click consecutively on:
      | Close | Update |
    Then the file format with name 'tiff' should have 0 logical extensions
    And I should see none of:
      | perl | pl (Perl) |
