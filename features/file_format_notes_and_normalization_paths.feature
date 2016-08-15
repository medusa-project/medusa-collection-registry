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
      | name                 | potential_for_loss    |
      | Normalization Path 1 | Big potential to lose |

  Scenario: See notes when viewing file format
    When I view the file format with name 'tiff'
    Then I should see 'My tiff note'
    And I should see 'Normalization Path 1'

  @javascript
  Scenario: Add note to file format
    Given I am logged in as an admin
    When I view the file format with name 'tiff'
    And I click on 'Add Note'
    And I fill in fields:
      | Note | My new note |
    And I click on 'Create'
    Then I should see 'My new note'
    And a file format note with note 'My new note' should exist

  Scenario: Delete note from file format
    Given I am logged in as an admin
    When I view the file format with name 'tiff'
    And I click on 'Delete Note'
    Then there should be no file format note with note 'My tiff note'
    And I should not see 'My tiff note'

  @javascript
  Scenario: Edit note of file format
    Given I am logged in as an admin
    When I view the file format with name 'tiff'
    And I click on 'Edit Note'
    And I fill in fields:
      | Note | Edited Note |
    And I click on 'Update'
    Then I should see 'Edited Note'
    And a file format note with note 'Edited Note' should exist

  @javascript
  Scenario: Add normalization path to file format
    Given I am logged in as an admin
    When I view the file format with name 'tiff'
    And I click on 'Add Normalization Path'
    And I fill in fields:
      | Name | My new path |
    And I click on 'Create'
    Then I should see 'My new path'
    And a file format normalization path with name 'My new path' should exist

  Scenario: Delete normalization path from file format
    Given I am logged in as an admin
    When I view the file format with name 'tiff'
    And I click on 'Delete Normalization Path'
    Then there should be no file format normalization path with name 'Normalization Path 1'
    And I should not see 'Normalization Path 1'

  @javascript
  Scenario: Edit normalization path of file format
    Given I am logged in as an admin
    When I view the file format with name 'tiff'
    And I click on 'Edit Normalization Path'
    And I fill in fields:
      | Software | Photoshop |
    And I click on 'Update'
    Then I should see 'Photoshop'
    And the file format normalization path with fields should exist:
      | name                 | software  |
      | Normalization Path 1 | Photoshop |

  Scenario: View normalization path
    When I view the file format with name 'tiff'
    And I click on 'Normalization Path 1'
    Then I should see 'Big potential to lose'
