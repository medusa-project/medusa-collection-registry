Feature: Access system authorization
  In order to protect the access systems
  As the system
  I want to enforce proper authorization

  Background:
    Given The access system named 'ContentDM' exists

  Scenario: View index as public should succeed
    Given I am not logged in
    When I go to the access system index page
    Then I should be on the access system index page

  Scenario: View show as public should succeed
    Given I am not logged in
    When I view the access system named 'ContentDM'
    Then I should be on the view page for the access system named 'ContentDM'

  Scenario: Edit/Update as medusa admin should succeed
    Given I am logged in as a medusa admin
    When I edit the access system named 'ContentDM'
    And I click on 'Update Access system'
    Then I should be on the view page for the access system named 'ContentDM'

  Scenario: Edit as logged in user should fail
    Then trying to edit the access system with name 'ContentDM' as a visitor should redirect to unauthorized

  Scenario: Edit as public user should go to authentication
    Then trying to edit the access system with name 'ContentDM' as a public user should redirect to authentication

  Scenario: Update as logged in user should fail
    Then trying to update the access system with name 'ContentDM' as a visitor should redirect to unauthorized

  Scenario: Update as public user should go to authentication
    Then trying to update the access system with name 'ContentDM' as a public user should redirect to authentication

  Scenario: New/Create as medusa admin should succeed
    Given I am logged in as a medusa admin
    When I start a new access system
    And I fill in fields:
      | Name | Ideals |
    And I click on 'Create Access system'
    Then the access system named 'Ideals' should exist

  Scenario: New as logged in user should fail
    Then trying to do new with the access system collection as a visitor should redirect to unauthorized

  Scenario: New as public user should go to authentication
    Then trying to do new with the access system collection as a public user should redirect to authentication

  Scenario: Create as logged in user should fail
    Then trying to do create with the access system collection as a visitor should redirect to unauthorized

  Scenario: Create as public user should go to authentication
    Then trying to do new with the access system collection as a public user should redirect to authentication

  Scenario: Delete as medusa admin should succeed
    Given I am logged in as a medusa admin
    When I view the access system named 'ContentDM'
    And I click on 'Delete'
    Then the access system named 'ContentDM' should not exist

  Scenario: Delete as logged in user should fail
    Then trying to delete the access system with name 'ContentDM' as a visitor should redirect to unauthorized

  Scenario: Delete as public user should go to authentication
    Then trying to delete the access system with name 'ContentDM' as a public user should redirect to authentication
