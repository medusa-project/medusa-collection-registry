Feature: Authentication
  In order to control access to Medusa
  As anyone
  I want to provide an authentication mechanism

  Scenario: Unauthenticated users are asked to log in
    Given I am not logged in
    When I go to the site home
    Then I should be on the login page

