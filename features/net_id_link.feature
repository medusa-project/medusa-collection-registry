Feature: Net ID links
  In order to manage preservation
  As a librarian
  I want to be able to get information about UIUC actors on the collections

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' is managed by 'hding2@example.com'

  Scenario: Link repository manager
    When I view the repository titled 'Animals'
    Then I should see an external link 'hding2@example.com' to the UIUC Net ID search
