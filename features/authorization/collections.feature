Feature: Collection authorization
  In order to protect the attachments
  As the system
  I want to enforce proper authorization

  Background:
    Given the repository titled 'Sample Repo' has collections with fields:
      | title | start_date | end_date   | published | ongoing | description |
      | dogs  | 2010-01-01 | 2012-02-02 | true      | true    | Dog stuff   |

  Scenario: View collection as a public user
    Then trying to view the collection with title 'dogs' as a public user should redirect to authentication

  Scenario: View collection index as a public user
    When I go to the collection index page
    Then I should be on the login page

  Scenario: Edit collection as a public user
    Then trying to edit the collection with title 'dogs' as a public user should redirect to authentication

  Scenario: Update collection as a public user
    Then trying to update the collection with title 'dogs' as a public user should redirect to authentication

  Scenario: Edit collection as a visitor
    Then trying to edit the collection with title 'dogs' as a visitor should redirect to unauthorized

  Scenario: Update collection as a visitor
    Then trying to update the collection with title 'dogs' as a visitor should redirect to unauthorized

  Scenario: Start new collection as public user
    Then trying to do new with the collection collection as a public user should redirect to authentication

  Scenario: Create new collection as public user
    Then trying to do create with the collection collection as a public user should redirect to authentication

  Scenario: Start new collection as visitor
    Then trying to do new with the collection collection as a visitor should redirect to unauthorized

  Scenario: Create new collection as visitor
    Then trying to do create with the collection collection as a visitor should redirect to unauthorized

  Scenario: Delete collection as a public user
    Then trying to delete the collection with title 'dogs' as a public user should redirect to authentication

  Scenario: Delete collection as a visitor
    Then trying to delete the collection with title 'dogs' as a visitor should redirect to unauthorized

  Scenario: Delete collection as a manager
    Then trying to delete the collection with title 'dogs' as a manager should redirect to unauthorized

  Scenario: View access system index for a collection as a public user
    Given The access system named 'DSpace' exists
    When I go to the access system index page
    And I click on 'DSpace'
    Then I should be on the login page

  Scenario: View public profile index for a collection as a public user
    Given the package profile named 'Profile' exists
    When I go to the package profile index page
    And I click on 'Profile'
    Then I should be on the login page

  Scenario: View red flags as a public user
    Then trying to events the collection with title 'dogs' as a public user should redirect to authentication

  Scenario: View events as a public user
    Then trying to red_flags the collection with title 'dogs' as a public user should redirect to authentication