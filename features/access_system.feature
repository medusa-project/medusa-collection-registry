Feature: Access Systems
  In order to facilitate preservation
  As a librarian
  I want to track the access systems used by a collection

  Background:
    Given I am logged in as an admin
    And The access system named 'ContentDM' exists
    And The access system named 'Dspace' exists

  Scenario: View index
    When I go to the access system index page
    Then I should be on the access system index page
    And I should see 'ContentDM'
    And I should see 'Dspace'

  Scenario: View an access system
    When I view the access system named 'ContentDM'
    Then I should be on the view page for the access system named 'ContentDM'
    And I should see 'Name'
    And I should see 'ContentDM'

  Scenario: Edit an access system
    When I edit the access system named 'ContentDM'
    And I fill in fields:
      | Name | Blacklight |
    And I press 'Update Access system'
    Then I should be on the view page for the access system named 'Blacklight'
    And There should be no access system named 'ContentDB'

  Scenario: Delete access system from view page
    When I view the access system named 'ContentDM'
    And I click on 'Delete'
    Then I should be on the access system index page
    And I should not see 'ContentDM'

  Scenario: Delete from index page
    When I go to the access system index page
    And I click on 'Delete'
    Then I should be on the access system index page
    And I should not see 'ContentDM'

  Scenario: Create from index page
    When I go to the access system index page
    And I click on 'New Access System'
    Then I should be on the access system creation page

  Scenario: Navigate from view page to index page
    When I view the access system named 'ContentDM'
    And I click on 'Index'
    Then I should be on the access system index page

  Scenario: Navigate from view page to edit page
    When I view the access system named 'ContentDM'
    And I click on 'Edit'
    Then I should be on the edit page for the access system named 'ContentDM'

  Scenario: View collections associated with an access system
    Given the collection titled 'Dogs' has an access system named 'ContentDM'
    And the collection titled 'Cats' has an access system named 'Dspace'
    And the collection titled 'Cats' has an access system named 'ContentDM'
    And the collection titled 'Bats' has an access system named 'Dspace'
    When I go to the access system index page
    And I click on 'ContentDM'
    Then I should be on the collection index page for collections with access system 'ContentDM'
    And I should see all of:
      | Dogs | Cats |
    And I should not see 'Bats'