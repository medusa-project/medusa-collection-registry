Feature: Total size of all repositories
  In order to track the full size of medusa
  As a librarian
  I want to see the reported size of all collections

  Scenario: View repository index to see total size
    Given I am logged in as an admin
    And I have some repositories with files totalling '25' GB
    When I go to the repository index page
    Then I should see '25 GB'


