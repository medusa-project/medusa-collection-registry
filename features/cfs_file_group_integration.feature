Feature: CFS file group integration
  In order to temporarily preserve and work with files before ingest
  As a librarian
  I want to be able to associate file groups with cfs directories

  Background:
    Given I am logged in as an admin
    And I clear the cfs root directory
    And the physical cfs directory 'dogs/toy-dogs' has a file 'document.doc' with contents 'does not matter'
    And the physical cfs directory 'dogs/toy-dogs/yorkies' has a file 'something.txt' with contents 'also irrelevant'
    And the collection with title 'Dogs' has child file groups with fields:
      | title | type              |
      | Toys  | BitLevelFileGroup |
    And the file group titled 'Toys' has cfs root 'dogs/toy-dogs' and delayed jobs are run

  @javascript @search
  Scenario: See file group's cfs root directory contents when viewing file group
    When I view the file group with title 'Toys'
    Then I should see the directory_files table
    And I should see all of:
      | document.doc | yorkies |

  Scenario: Set file group's cfs root from file group edit view
    Given there is a physical cfs directory 'englishmen/yorkies'
    When I edit the file group with title 'Toys'
    And I select 'englishmen/yorkies' from 'Cfs root'
    And I click on 'Update'
    Then the file group titled 'Toys' should have root cfs directory with path 'englishmen/yorkies'

  Scenario: See that a cfs directory belongs to a file group when viewing it
    When I view the cfs directory for the file group titled 'Toys' for the path 'yorkies'
    Then I should see 'Toys'

  Scenario: Navigate from a cfs directory to the owning file group
    When I view the cfs directory for the file group titled 'Toys' for the path 'yorkies'
    And I click on 'Toys'
    Then I should be on the view page for the file group with title 'Toys'

  Scenario: Redirect from root cfs directory to file group if present
    When I view the cfs directory for the file group titled 'Toys' for the path '.'
    Then I should be on the view page for the file group with title 'Toys'

  Scenario: Navigate from a cfs file to the owning file group
    And I view the cfs file for the file group titled 'Toys' for the path 'document.doc'
    And I click on 'Toys'
    Then I should be on the view page for the file group with title 'Toys'