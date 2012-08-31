Feature: Root navigation
  In order to have a start page
  As any user
  I want to land on a defined starting page

  Scenario: Go to site home
    Given I am logged in as an admin
    And I go to the site home
    Then I should see 'New Repository'