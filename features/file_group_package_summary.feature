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
      | external_file_location | summary | provenance_note  |
      | Grainger      | Summation of package  | Provenance information |

  Scenario: View file group to see package summary
    When I view the file group with location 'Grainger' for the collection titled 'Dogs'
    Then I should see all of:
      | Summation of package | Provenance information|
    And I should see all of:
      | Summary | Provenance Note |

  Scenario: Update file group package summary fields
    When I edit the file group with location 'Grainger' for the collection titled 'Dogs'
    And I fill in fields:
      | Summary | New summary    |
      | Provenance Note   | New provenance |
    And I click on 'Update File group'
    Then I should see all of:
      | New summary | New provenance |


