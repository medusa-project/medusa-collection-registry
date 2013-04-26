Feature: CFS file group integration
  In order to temporarily preserve and work with files before ingest
  As a librarian
  I want to be able to associate file groups with cfs directories

  Background:
    Given I am logged in as an admin
    And I clear the cfs root directory
    And there is a cfs directory 'dogs/toy-dogs/yorkies'
    And the collection titled 'Dogs' has file groups with fields:
      | name | type              |
      | Toys | BitLevelFileGroup |
    And the file group named 'Toys' has cfs root 'dogs/toy-dogs'

  Scenario: See file group's cfs root when viewing it
    When I view the file group named 'Toys'
    Then I should see 'toy-dogs'

  Scenario: Navigate from file group to its cfs root
    When I view the file group named 'Toys'
    And I click on 'toy-dogs'
    Then I should be viewing the cfs directory 'dogs/toy-dogs'

  Scenario: Set file group's cfs root from file group edit view
    Given there is a cfs directory 'englishmen/yorkies'
    When I edit the file group named 'Toys'
    And I select 'englishmen/yorkies' from 'Cfs root'
    And I click on 'Update File group'
    Then the file group named 'Toys' should have cfs root 'englishmen/yorkies'

  Scenario: See that a cfs directory belongs to a file group when viewing it
    When I view the cfs path 'dogs/toy-dogs/yorkies'
    Then I should see 'Toys'

  Scenario: Navigate from a cfs directory to the owning file group
    When I view the cfs path 'dogs/toy-dogs'
    And I click on 'Toys'
    Then I should be on the view page for the file group named 'Toys'

  Scenario: Navigate from a cfs file to the owning file group
    When the cfs directory 'dogs/toy-dogs' has files:
      | picture.jpg |
    And I view the cfs path 'dogs/toy-dogs/picture.jpg'
    And I click on 'Toys'
    Then I should be on the view page for the file group named 'Toys'