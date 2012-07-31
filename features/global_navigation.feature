Feature: Global navigation
  In order to more efficiently use the application
  As anyone
  I want to be able to navigate to the 'root' indexes easily

  Background:
    Given I am logged in
    When I go to the site home

  Scenario: View global navigation
    Then I should see a global navigation bar

  Scenario: Go to repository index
    When I click on 'Repositories' in the global navigation bar
    Then I should be on the repository index page

  Scenario: Go to the access system index
    When I click on 'Access Systems' in the global navigation bar
    Then I should be on the access system index page

  Scenario: Go to production units
    When I click on 'Production Units' in the global navigation bar
    Then I should be on the production unit index page

  Scenario: Go to collections
    When I click on 'Collections' in the global navigation bar
    Then I should be on the collection index page
