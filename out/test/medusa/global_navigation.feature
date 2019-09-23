Feature: Global navigation
  In order to more efficiently use the application
  As anyone
  I want to be able to navigate to the 'root' indexes easily

  Background:
    Given I am logged in as an admin
    When I go to the site home

  Scenario: View global navigation
    Then I should see a global navigation bar

  Scenario: Go to repository index
    When I click on 'Repositories' in the global navigation bar
    Then I should be on the repository index page

  Scenario: Go to the access system index
    When I click on 'Access' in the global navigation bar
    Then I should be on the access system index page

  Scenario: Go to producers
    When I click on 'Producer' in the global navigation bar
    Then I should be on the producer index page

  Scenario: Go to collections
    When I click on 'Collections' in the global navigation bar
    Then I should be on the collection index page

  Scenario: Go to dashboard
    When I click on 'Dashboard' in the global navigation bar
    Then I should be on the dashboard page


