Feature: Link to wiki
  In order to see documentation, etc. on the wiki
  As any user
  I want to have a link to the wiki

  Background:
    Given I am logged in as an admin

    Scenario: Link in navbar and home page body
      When I go to the site home
      Then I should see a link to the wiki in the body
      And I should see a link to the wiki in the navbar
