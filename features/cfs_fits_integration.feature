Feature: CFS FITS integration
  In order to assess staged files
  As a librarian
  I want to be able to run FITS against files in the CFS directory

  Background:
    Given I clear the cfs root directory
    And there is a physical cfs directory 'dogs/toy-dogs'
    And there is a physical cfs directory 'dogs/toy-dogs/pictures'
    And the physical cfs directory 'dogs/toy-dogs' has a file 'text.txt' with contents 'some text'
    And the physical cfs directory 'dogs/toy-dogs/pictures' has a file 'picture.txt' with contents 'more text'
    And the collection titled 'Dogs' has file groups with fields:
      | name | type              |
      | Toys | BitLevelFileGroup |
    And the file group named 'Toys' has cfs root 'dogs/toy-dogs'

  Scenario: Run fits on a file
    Given I am logged in as an admin
    When I view the cfs directory for the file group named 'Toys' for the path '.'
    And I click on 'Create XML'
    Then I should be viewing the cfs root directory for the file group named 'Toys'
    And the file group named 'Toys' should have a cfs file for the path 'text.txt' with fits attached

  Scenario: Run fits on a file as a manager
    Given I am logged in as a manager
    When I view the cfs directory for the file group named 'Toys' for the path '.'
    And I click on 'Create XML'
    Then I should be viewing the cfs root directory for the file group named 'Toys'
    And the file group named 'Toys' should have a cfs file for the path 'text.txt' with fits attached

  Scenario: Run fits on a file as a visitor
    Given I am logged in as a visitor
    When I view the cfs directory for the file group named 'Toys' for the path '.'
    And I click on 'Create XML'
    Then I should be unauthorized

  Scenario: View fits on a file as an admin
    Given I am logged in as an admin
    And the cfs file at path 'text.txt' for the file group named 'Toys' has fits attached
    When I view the cfs directory for the file group named 'Toys' for the path '.'
    And I click on 'View XML'
    Then I should be on the fits info page for the cfs file at path 'text.txt' for the file group named 'Toys'

  Scenario: View fits on a file as a manager
    Given I am logged in as a manager
    And the cfs file at path 'text.txt' for the file group named 'Toys' has fits attached
    When I view the cfs directory for the file group named 'Toys' for the path '.'
    And I click on 'View XML'
    Then I should be on the fits info page for the cfs file at path 'text.txt' for the file group named 'Toys'

  Scenario: View fits on a file as a visitor
    Given I am logged in as a visitor
    And the cfs file at path 'text.txt' for the file group named 'Toys' has fits attached
    When I view the cfs directory for the file group named 'Toys' for the path '.'
    And I click on 'View XML'
    Then I should be on the fits info page for the cfs file at path 'text.txt' for the file group named 'Toys'

  Scenario: View fits on a file as a public user
    Given I am not logged in
    And the cfs file at path 'text.txt' for the file group named 'Toys' has fits attached
    When I view the cfs directory for the file group named 'Toys' for the path '.'
    Then I should be on the login page

  Scenario: Run fits on a whole directory tree
    Given I am logged in as an admin
    When I view the cfs directory for the file group named 'Toys' for the path '.'
    And I click on 'Create FITS for tree'
    And the file group named 'Toys' should have a cfs file for the path 'text.txt' with fits attached
    And the file group named 'Toys' should have a cfs file for the path 'pictures/picture.txt' with fits attached
    And I should see 'Scheduling FITS creation for /dogs/toy-dogs'

  Scenario: Run fits on a whole directory tree as manager
    Given I am logged in as a manager
    When I view the cfs directory for the file group named 'Toys' for the path '.'
    And I click on 'Create FITS for tree'
    And the file group named 'Toys' should have a cfs file for the path 'text.txt' with fits attached
    And the file group named 'Toys' should have a cfs file for the path 'pictures/picture.txt' with fits attached
    And I should see 'Scheduling FITS creation for /dogs/toy-dogs'

  Scenario: Run fits on a directory tree as a visitor
    Given I am logged in as a visitor
    When I view the cfs directory for the file group named 'Toys' for the path '.'
    And I click on 'Create FITS for tree'
    Then I should be unauthorized

  Scenario: Run fits on a file group as an admin
    Given I am logged in as an admin
    When I view the file group named 'Toys'
    And I click on 'Create FITS for CFS tree'
    Then the file group named 'Toys' should have a cfs file for the path 'text.txt' with fits attached
    And the file group named 'Toys' should have a cfs file for the path 'pictures/picture.txt' with fits attached
    And I should see 'Scheduling FITS creation for /dogs/toy-dogs'
    And the file group named 'Toys' should have an event with key 'cfs_fits_performed' performed by 'admin'

  Scenario: Run fits on a file group as an admin as a manager
    Given I am logged in as a manager
    When I view the file group named 'Toys'
    And I click on 'Create FITS for CFS tree'
    Then the file group named 'Toys' should have a cfs file for the path 'text.txt' with fits attached
    And the file group named 'Toys' should have a cfs file for the path 'pictures/picture.txt' with fits attached
    And I should see 'Scheduling FITS creation for /dogs/toy-dogs'
    And the file group named 'Toys' should have an event with key 'cfs_fits_performed' performed by 'manager'
