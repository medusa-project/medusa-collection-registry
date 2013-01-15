Feature: Authentication
  In order to control access to Medusa
  As anyone
  I want to provide an authentication mechanism

  Scenario: Unauthenticated users are asked to log in if they visit a restricted page
    Given I am not logged in
    And There is a collection titled 'Dogs'
    When I edit the collection titled 'Dogs'
    Then I should be on the login page

  Scenario: Log out
    Given I am logged in as an admin
    When I click on 'Logout' in the global navigation bar
    And I should be on the site home page

  Scenario: There is a login link for those not logged in
    Given I am not logged in
    And I go to the site home
    When I click on 'Login' in the global navigation bar
    Then I should be on the login page


