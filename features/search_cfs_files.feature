Feature: Search CFS Files
  In order to quickly locate files in which I have interest
  As a user
  I want to be able to search some fields of cfs files

  Background:
    Given I am logged in as an admin
    And there are cfs files with fields:
      | name        |
      | dog.txt     |
      | Doggies.txt |
      | cats.jpg    |

  Scenario: Navigate to search page
    When I go to the dashboard
    And I click on 'Search'
    Then I should be on the search page

  Scenario: Public users cannot access search page
    When I logout
    And I go to the search page
    Then I should be on the login page

  Scenario: Public users cannot perform searches
    When I logout
    Then trying to do post with the path 'filename_searches_path' as a public user should redirect to authentication

  Scenario: Search and find for exact string
    When I go to the search page
    And I fill in fields:
      | File name | dog.txt |
    And I click on 'Search filenames'
    Then I should see a table of cfs files with 1 row
    And I should see 'dog.txt'

  Scenario: Search for and do not find exact string
    When I go to the search page
    And I fill in fields:
      | File name | joebob.txt |
    And I click on 'Search filenames'
    Then I should see 'No files found with name joebob.txt.'

  Scenario: Wildcard search
    When I go to the search page
    And I fill in fields:
      | File name | dog* |
    And I click on 'Search filenames'
    Then I should see a table of cfs files with 2 rows
    And I should see all of:
      | dog.txt | Doggies.txt |
    And I should not see 'cats.jpg'
