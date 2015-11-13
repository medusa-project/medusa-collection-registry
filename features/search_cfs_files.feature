@search @javascript
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

  Scenario: Public users do not see search
    When I logout
    And I go to the site home
    Then there is no filename search box

  Scenario: Public users cannot perform searches
    When I logout
    Then trying to do post with the path 'search_searches_path' as a public user should redirect to authentication

  Scenario: Search and find for exact string
    When I go to the site home
    And I do a search for 'dog.txt'
    Then I should see a search table of cfs files with 1 row
    And I should see 'dog.txt'

  Scenario: Search for and do not find exact string
    When I go to the site home
    And I do a search for 'joebob.txt'
    Then I should see 'No matching records found'

  Scenario: Wildcard search
    When I go to the site home
    And I do a search for 'dog*'
    Then I should see a search table of cfs files with 2 rows
    And I should see all of:
      | dog.txt | Doggies.txt |
    And I should not see 'cats.jpg'
