Feature: Collection Registry Dashboard
  In order to view a summary of collection registry wide information
  As a librarian
  I want to have a dashboard view that shows it

  Background:
    Given I am logged in as an admin

  Scenario: Dashboard sections are present
    When I go to the dashboard
    Then The dashboard should have a storage overview section
    And The dashboard should have a running processes section
    And The dashboard should have a file statistics section
    And The dashboard should have a red flags section



