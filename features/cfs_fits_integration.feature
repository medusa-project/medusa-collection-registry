Feature: CFS FITS integration
  In order to assess staged files
  As a librarian
  I want to be able to run FITS against files in the CFS directory

  Background:
    Given PENDING
    Given I clear the cfs root directory
    And there is a cfs directory 'dogs/toy-dogs'
    And the collection titled 'Dogs' has file groups with fields:
      | name | type              |
      | Toys | BitLevelFileGroup |
    And the file group named 'Toys' has cfs root 'dogs/toy-dogs'
    And the cfs directory 'dogs/toy-dogs' has files:
      | text.txt |

  Scenario: Run fits on a file
    Given I am logged in as an admin
    When I view the cfs path 'dogs/toy-dogs'
    And I click on 'Create XML'
    Then I should be viewing the cfs directory 'dogs/toy-dogs'
    And the cfs file 'dogs/toy-dogs/text.txt' should have FITS xml attached

  Scenario: Run fits on a file as a manager
    Given I am logged in as a manager
    When I view the cfs path 'dogs/toy-dogs'
    And I click on 'Create XML'
    Then I should be viewing the cfs directory 'dogs/toy-dogs'
    And the cfs file 'dogs/toy-dogs/text.txt' should have FITS xml attached

  Scenario: Run fits on a file as a visitor
    Given I am logged in as a visitor
    When I view the cfs path 'dogs/toy-dogs'
    And I click on 'Create XML'
    Then I should be unauthorized

  Scenario: View fits on a file as an admin
    Given I am logged in as an admin
    Given the cfs file 'dogs/toy-dogs/text.txt' has FITS xml attached
    When I view the cfs path 'dogs/toy-dogs'
    And I click on 'View XML'
    Then I should be on the fits info page for the cfs file 'dogs/toy-dogs/text.txt'

  Scenario: View fits on a file as a manager
    Given I am logged in as a manager
    Given the cfs file 'dogs/toy-dogs/text.txt' has FITS xml attached
    When I view fits for the cfs file 'dogs/toy-dogs/text.txt'
    Then I should be on the fits info page for the cfs file 'dogs/toy-dogs/text.txt'

  Scenario: View fits on a file as a visitor
    Given I am logged in as a visitor
    Given the cfs file 'dogs/toy-dogs/text.txt' has FITS xml attached
    When I view fits for the cfs file 'dogs/toy-dogs/text.txt'
    Then I should be on the fits info page for the cfs file 'dogs/toy-dogs/text.txt'

  Scenario: View fits on a file as a public user
    Given I am not logged in
    Given the cfs file 'dogs/toy-dogs/text.txt' has FITS xml attached
    When I view fits for the cfs file 'dogs/toy-dogs/text.txt'
    Then I should be on the login page

  Scenario: Run fits on a whole directory tree
    Given I am logged in as an admin
    Given the cfs directory 'dogs/toy-dogs' has files:
      | picture.jpg |
    When I view the cfs path 'dogs/toy-dogs'
    And I click on 'Create FITS for tree'
    Then the cfs file 'dogs/toy-dogs/picture.jpg' should have FITS xml attached
    And the cfs file 'dogs/toy-dogs/text.txt' should have FITS xml attached
    And I should see 'Scheduling FITS creation for /dogs/toy-dogs'

  Scenario: Run fits on a whole directory tree as manager
      Given I am logged in as a manager
      Given the cfs directory 'dogs/toy-dogs' has files:
        | picture.jpg |
      When I view the cfs path 'dogs/toy-dogs'
      And I click on 'Create FITS for tree'
      Then the cfs file 'dogs/toy-dogs/picture.jpg' should have FITS xml attached
      And the cfs file 'dogs/toy-dogs/text.txt' should have FITS xml attached
      And I should see 'Scheduling FITS creation for /dogs/toy-dogs'

  Scenario: Run fits on a directory tree as a visitor
    Given I am logged in as a visitor
    When I view the cfs path 'dogs'
    And I click on 'Create FITS for tree'
    Then I should be unauthorized

  Scenario: Run fits on a file group as an admin
    Given I am logged in as an admin
    Given the file group named 'Toys' has cfs root 'dogs'
    And the cfs directory 'dogs' has files:
      | picture.jpg |
    When I view the file group named 'Toys'
    And I click on 'Create FITS for CFS tree'
    Then the cfs file 'dogs/picture.jpg' should have FITS xml attached
    And the cfs file 'dogs/toy-dogs/text.txt' should have FITS xml attached
    And I should see 'Scheduling FITS creation for /dogs'
    And the file group named 'Toys' should have an event with key 'cfs_fits_performed' performed by 'admin'

  Scenario: Run fits on a file group as an admin as a manager
    Given I am logged in as a manager
    And the file group named 'Toys' has cfs root 'dogs'
    And the cfs directory 'dogs' has files:
      | picture.jpg |
    When I view the file group named 'Toys'
    And I click on 'Create FITS for CFS tree'
    Then the cfs file 'dogs/picture.jpg' should have FITS xml attached
    And the cfs file 'dogs/toy-dogs/text.txt' should have FITS xml attached
    And I should see 'Scheduling FITS creation for /dogs'
    And the file group named 'Toys' should have an event with key 'cfs_fits_performed' performed by 'manager'
