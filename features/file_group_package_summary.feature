Feature: Package summary
  In order to facilitate preservation
  As a librarian
  I want to be able to record various pieces of information about the files in a file group

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | file_location | naming_conventions | file_hierarchy  | file_types      | origin            | misc_notes  |
      | Grainger      | File naming notes  | Hierarchy notes | File type notes | File origin notes | Misc. notes |

  Scenario: View file group to see package summary
    When I view the file group with location 'Grainger' for the collection titled 'Dogs'
    Then I should see all of:
      | File naming notes | Hierarchy notes | File type notes | File origin notes | Misc. notes |
    And I should see all of:
      | Naming Conventions | File Hierarchy | File Types | Origin | Misc. Notes |

  Scenario: Editing file group has field set for package summary fields
    When I edit the file group with location 'Grainger' for the collection titled 'Dogs'
    Then There should be a field set for the file group package summary

  Scenario: Update file group package summary fields
    When I edit the file group with location 'Grainger' for the collection titled 'Dogs'
    And I fill in fields:
      | Naming conventions | New naming    |
      | File hierarchy     | New hierarchy |
      | File types         | New types     |
      | Origin             | New origin    |
      | Misc. notes        | New notes     |
    And I click on 'Update File group'
    Then I should see all of:
      | New naming | New hierarchy | New types | New origin | New notes |


