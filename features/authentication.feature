Feature: Authentication
  In order to control access to Medusa
  As anyone
  I want to provide an authentication mechanism

  Scenario: Unauthenticated users are asked to log in
    Given I am not logged in
    When I go to the site home
    Then I should be on the login page

  Scenario: Log out
    Given I am logged in as an admin
    When I click on 'Logout' in the global navigation bar
    And I should be on the login page



