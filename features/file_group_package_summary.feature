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
      | name     | external_file_location | summary              | provenance_note        |
      | grainger | Grainger               | Summation of package | Provenance information |

  Scenario: View file group to see package summary
    When I view the file group with name 'grainger'
    Then I should see all of:
      | Summation of package | Provenance information |
    And I should see all of:
      | Summary | Provenance Note |

  Scenario: Update file group package summary fields
    When I edit the file group with name 'grainger'
    And I fill in fields:
      | Summary         | New summary    |
      | Provenance Note | New provenance |
    And I click on 'Update File group'
    Then I should see all of:
      | New summary | New provenance |


