Feature: Package summary
  In order to facilitate preservation
  As a librarian
  I want to be able to record various pieces of information about the files in a file group

  Background:
    Given I am logged in as an admin
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | title    | external_file_location | description          | provenance_note        |
      | grainger | Grainger               | Summation of package | Provenance information |

  Scenario: View file group to see package summary
    When I view the file group with title 'grainger'
    Then I should see all of:
      | Summation of package | Provenance information |
    And I should see all of:
      | Description | Provenance Note |

  Scenario: Update file group package summary fields
    When I edit the file group with title 'grainger'
    And I fill in fields:
      | Description         | New summary    |
      | Provenance Note | New provenance |
    And I click on 'Update'
    Then I should see all of:
      | New summary | New provenance |


