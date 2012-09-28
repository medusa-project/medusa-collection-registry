Feature: Public landing Page
  In order to welcome visitors
  As the system
  I want to have an informational landing page

  Background:
    Given I am logged in as a visitor

  Scenario: Visit the landing page
    When I go to the site home
    Then I should be on the site home page
    And I should see introductory text about Medusa