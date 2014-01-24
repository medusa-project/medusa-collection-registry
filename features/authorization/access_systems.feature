Feature: Access system authorization
  In order to protect the access systems
  As the system
  I want to enforce proper authorization

  Background:
    Given The access system named 'ContentDM' exists

  Scenario: Edit as logged in user should fail
    Then trying to edit the access system with name 'ContentDM' as a visitor should redirect to unauthorized

  Scenario: Edit as public user should go to authentication
    Then trying to edit the access system with name 'ContentDM' as a public user should redirect to authentication

  Scenario: Update as logged in user should fail
    Then trying to update the access system with name 'ContentDM' as a visitor should redirect to unauthorized

  Scenario: Update as public user should go to authentication
    Then trying to update the access system with name 'ContentDM' as a public user should redirect to authentication

  Scenario: New as logged in user should fail
    Then trying to do new with the access system collection as a visitor should redirect to unauthorized

  Scenario: New as public user should go to authentication
    Then trying to do new with the access system collection as a public user should redirect to authentication

  Scenario: Create as logged in user should fail
    Then trying to do create with the access system collection as a visitor should redirect to unauthorized

  Scenario: Create as public user should go to authentication
    Then trying to do new with the access system collection as a public user should redirect to authentication

  Scenario: Delete as logged in user should fail
    Then trying to delete the access system with name 'ContentDM' as a visitor should redirect to unauthorized

  Scenario: Delete as public user should go to authentication
    Then trying to delete the access system with name 'ContentDM' as a public user should redirect to authentication
