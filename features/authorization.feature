Feature: Authorization
  In order to control access to myself
  As the system
  I want to be able to check user's authorizations

  Scenario: A visitor should not be able to view anything
    Given I am logged in as 'visitor'
    When I go to the repository index page
    Then I should be redirected to the unauthorized page
    And I should see 'You are not authorized to view the requested page.'