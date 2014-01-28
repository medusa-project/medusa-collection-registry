Feature: Dashboard authorization
  In order to protect the dashboard
  As the system
  I want to enforce proper authorization

  Scenario: View the dashboard as a public user
    Given I am not logged in
    When I go to the dashboard
    Then I should be on the login page