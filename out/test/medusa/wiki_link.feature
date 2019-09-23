Feature: Link to wiki
  In order to see documentation, etc. on the wiki
  As any user
  I want to have a link to the wiki

  Background:
    Given I am logged in as an admin

    Scenario: Link in navbar
      When I go to the site home
      And I should see a link to the wiki in the navbar
