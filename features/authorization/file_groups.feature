Feature: File group authorization
  In order to protect file groups
  As the system
  I want to enforce proper authorization

  Background:
    Given the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | name   |
      | images |

  Scenario: Public user tries to view a file group
    Given I am not logged in
    And I view the file group named 'images'
    Then I should be on the login page

  Scenario: Public user tries to edit a file group
    Then trying to edit the file group with name 'images' as a public user should redirect to authentication

  Scenario: Public user tries to update a file group
    Then trying to update the file group with name 'images' as a public user should redirect to authentication

  Scenario: Visitor tries to to edit a file group
    Then trying to edit the file group with name 'images' as a visitor should redirect to unauthorized

  Scenario: Visitor tries to to update a file group
    Then trying to update the file group with name 'images' as a visitor should redirect to unauthorized

  Scenario: Public user tries to start a file group
    Then trying to do new with the file group collection as a public user should redirect to authentication

  Scenario: Public user tries to create a file group
    Then trying to do create with the file group collection as a public user should redirect to authentication

  Scenario: Visitor tries to start a file group
    Then a visitor is unauthorized to start a file group for the collection titled 'Dogs'

  Scenario: Visitor tries to create a file group
    Then a visitor is unauthorized to create a file group for the collection titled 'Dogs'

  Scenario: Public user tries to create cfs fits for a file group
    Then trying to create_cfs_fits via post the file group with name 'images' as a public user should redirect to authentication

  Scenario: Visitor tries to create cfs fits for a file group
    Then trying to create_cfs_fits via post the file group with name 'images' as a visitor should redirect to unauthorized

  Scenario: Public user tries to create virus scan for a file group
    Then trying to create_virus_scan via post the file group with name 'images' as a public user should redirect to authentication

  Scenario: Visitor tries to create virus scan for a file group
    Then trying to create_virus_scan via post the file group with name 'images' as a visitor should redirect to unauthorized

  Scenario: Public user tries to view events for a file group
    Then trying to events the file group with name 'images' as a public user should redirect to authentication

  Scenario: Public user tries to view red flags for a file group
    Then trying to red_flags the file group with name 'images' as a public user should redirect to authentication

