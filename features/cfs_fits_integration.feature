Feature: CFS FITS integration
  In order to assess staged files
  As a librarian
  I want to be able to run FITS against files in the CFS directory

  Background:
    Given I am logged in as an admin
    And I clear the cfs root directory
    And there is a cfs directory 'dogs/toy-dogs'
    And the collection titled 'Dogs' has file groups with fields:
      | name |
      | Toys |
    And the file group named 'Toys' has cfs root 'dogs/toy-dogs'
    And the cfs directory 'dogs/toy-dogs' has files:
      | text.txt |

  Scenario: Run fits on a file
    When I view the cfs path 'dogs/toy-dogs'
    And I click on 'Create XML'
    Then I should be viewing the cfs directory 'dogs/toy-dogs'
    And the cfs file 'dogs/toy-dogs/text.txt' should have FITS xml attached

  Scenario: View fits on a file
    Given the cfs file 'dogs/toy-dogs/text.txt' has FITS xml attached
    When I view the cfs path 'dogs/toy-dogs'
    And I click on 'View XML'
    Then I should be on the fits info page for the cfs file 'dogs/toy-dogs/text.txt'


  Scenario: Run fits on a whole directory tree
    When PENDING

  Scenario: Run fits on a file group
    When PENDING