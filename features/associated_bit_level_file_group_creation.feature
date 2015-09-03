Feature: Automatic creation of bit level file group associated with external file group
  In order to streamline the accrual/ingestion workflow
  As a librarian
  I want to be able to create a bit level file group associated with an external file group

  Background:
    Given the external file group with title 'Dogs' exists

  #I.e. we have an external file group without a corresponding bit level file group and
  #we have appropriate permissions. We get redirected to the bit level file group at the end.
  Scenario: I create a bit level file group if preconditions are met
    Given I am logged in as a manager
    When I view the external file group with title 'Dogs'
    And I click on 'Create Bit Level File Group'
    Then a bit level file group with title 'Dogs' should exist
    And I should be on the view page for the bit level file group with title 'Dogs'
    And I should see 'No files have been added yet'
    And the bit level file group with title 'Dogs' should have an event with key 'created' performed by 'manager@example.com'

  Scenario: There is not a button if there is already a related bit level file group
    Given the external file group with title 'Dogs' has a related bit level file group
    And I am logged in as a manager
    When I view the external file group with title 'Dogs'
    Then I should not see 'Create Bit Level File Group'

  Scenario: There is not a button if I am not a manager of the external file group
    Given I am logged in as a visitor
    When I view the external file group with title 'Dogs'
    Then I should not see 'Create Bit Level File Group'