Feature: Producers authorization
  In order to protect producers
  As the system
  I want to enforce proper authorization

  Background:
    Given I have producers with fields:
      | title    | address_1      | address_2 | city   | state    | zip   | phone_number | email                | url                         | notes                |
      | Scanning | 100 Elm Street | Suite 10  | Urbana | Illinois | 61801 | 555-2345     | scanning@example.com | http://scanning.example.com | They scan stuff here. http://notes.example.com |

  Scenario: View producer as a public user
    Given I am not logged in
    When I view the producer titled 'Scanning'
    Then I should be on the login page

  Scenario: View index as a public user
    Given I am not logged in
    When I go to the producer index page
    Then I should be on the login page

  Scenario: Edit producer as a public user
    Then trying to edit the producer with title 'Scanning' as a public user should redirect to authentication

  Scenario: Edit producer as a manager
    Then trying to edit the producer with title 'Scanning' as a manager should redirect to unauthorized

  Scenario: Edit producer as a visitor
    Then trying to edit the producer with title 'Scanning' as a visitor should redirect to unauthorized

  Scenario: Update producer as a public user
    Then trying to update the producer with title 'Scanning' as a public user should redirect to authentication

  Scenario: Update producer as a manager
    Then trying to update the producer with title 'Scanning' as a manager should redirect to unauthorized

  Scenario: Update producer as a visitor
    Then trying to update the producer with title 'Scanning' as a visitor should redirect to unauthorized

  Scenario: Destroy producer as a public user
    Then trying to destroy the producer with title 'Scanning' as a public user should redirect to authentication

  Scenario: Destroy producer as a manager
    Then trying to destroy the producer with title 'Scanning' as a manager should redirect to unauthorized

  Scenario: Destroy producer as a visitor
    Then trying to destroy the producer with title 'Scanning' as a visitor should redirect to unauthorized

  Scenario: Start producer as public user
    Then trying to do new with the producer collection as a public user should redirect to authentication

  Scenario: Start producer as manager
    Then trying to do new with the producer collection as a manager should redirect to unauthorized

  Scenario: Start producer as visitor
    Then trying to do new with the producer collection as a visitor should redirect to unauthorized

  Scenario: Create producer as public user
    Then trying to do create with the producer collection as a public user should redirect to authentication

  Scenario: Create producer as manager
    Then trying to do create with the producer collection as a manager should redirect to unauthorized

  Scenario: Create producer as visitor
    Then trying to do create with the producer collection as a visitor should redirect to unauthorized
