Feature: Package Profiles authorization
  In order to protect package profiles
  As the system
  I want to enforce proper authorization

  Background:
    Given I have package profiles with fields:
      | name | url                             | notes                          |
      | book | http://book_profile.example.com | Preservation package for books |


  Scenario: Try to view package profile as a public user
    Then trying to view the package profile with name 'book' as a public user should redirect to authentication

  Scenario: Edit a package profile as a public user
    Then trying to edit the package profile with name 'book' as a public user should redirect to authentication

  Scenario: Edit a package profile as a manager
    Then trying to edit the package profile with name 'book' as a manager should redirect to unauthorized

  Scenario: Edit a package profile as a visitor
    Then trying to edit the package profile with name 'book' as a visitor should redirect to unauthorized

  Scenario: Update a package profile as a public user
    Then trying to update the package profile with name 'book' as a public user should redirect to authentication

  Scenario: Update a package profile as a manager
    Then trying to update the package profile with name 'book' as a manager should redirect to unauthorized

  Scenario: Update a package profile as a visitor
    Then trying to update the package profile with name 'book' as a visitor should redirect to unauthorized

  Scenario: Destroy a package profile as a public user
    Then trying to delete the package profile with name 'book' as a public user should redirect to authentication

  Scenario: Destroy a package profile as a manager
    Then trying to delete the package profile with name 'book' as a manager should redirect to unauthorized

  Scenario: Destroy a package profile as a visitor
    Then trying to delete the package profile with name 'book' as a visitor should redirect to unauthorized

  Scenario: Start a packager profile as a public user
    Then trying to do new with the package profile collection as a public user should redirect to authentication

  Scenario: Start a packager profile as a manager
    Then trying to do new with the package profile collection as a manager should redirect to unauthorized

  Scenario: Start a packager profile as a visitor
    Then trying to do new with the package profile collection as a visitor should redirect to unauthorized

  Scenario: Create a packager profile as a public user
    Then trying to do create with the package profile collection as a public user should redirect to authentication

  Scenario: Create a packager profile as a manager
    Then trying to do create with the package profile collection as a manager should redirect to unauthorized

  Scenario: Create a packager profile as a visitor
    Then trying to do create with the package profile collection as a visitor should redirect to unauthorized