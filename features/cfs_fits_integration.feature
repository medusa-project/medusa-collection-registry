Feature: CFS FITS integration
  In order to assess staged files
  As a librarian
  I want to be able to run FITS against files in the CFS directory

  Background:
    Given the main storage has a key 'dogs/toy-dogs/text.txt' with contents 'some text'
    And the main storage has a key 'dogs/toy-dogs/pictures/picture.txt' with contents 'more text'
    And the collection with title 'Dogs' has child file groups with fields:
      | title | type              |
      | Toys | BitLevelFileGroup |
    And the file group titled 'Toys' has cfs root 'dogs/toy-dogs' and delayed jobs are run

  @javascript @search
  Scenario: View fits on a file as an admin
    Given I am logged in as an admin
    And the cfs file at path 'pictures/picture.txt' for the file group titled 'Toys' has fits attached
    When I view the cfs directory for the file group titled 'Toys' for the path 'pictures'
    And I click on 'View'
    Then I should be on the fits info page for the cfs file at path 'pictures/picture.txt' for the file group titled 'Toys'

  @javascript @search
  Scenario: View fits on a file as a manager
    Given I am logged in as a manager
    And the cfs file at path 'pictures/picture.txt' for the file group titled 'Toys' has fits attached
    When I view the cfs directory for the file group titled 'Toys' for the path 'pictures'
    And I click on 'View'
    Then I should be on the fits info page for the cfs file at path 'pictures/picture.txt' for the file group titled 'Toys'

  @javascript @search
  Scenario: View fits on a file as a user
    Given I am logged in as a user
    And the cfs file at path 'pictures/picture.txt' for the file group titled 'Toys' has fits attached
    When I view the cfs directory for the file group titled 'Toys' for the path 'pictures'
    And I click on 'View'
    Then I should be on the fits info page for the cfs file at path 'pictures/picture.txt' for the file group titled 'Toys'

  Scenario: View fits on a file as a public user
    Given I am not logged in
    And the cfs file at path 'pictures/picture.txt' for the file group titled 'Toys' has fits attached
    When I view the cfs directory for the file group titled 'Toys' for the path 'pictures'
    Then I should be on the login page
