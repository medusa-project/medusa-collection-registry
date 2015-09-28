Feature: Collection projects table
  In order to track projects associated with a collection
  As a librarian
  I want the collection view page to have a table of projects

  Background:
    Given the collection with title 'Dogs' has child projects with field title:
      | Toys | Hounds | Retrievers |

  Scenario: The collection view page has a table of projects
    Given I am logged in as an admin
    When I view the collection with title 'Dogs'
    Then I should see the projects table
    And I should see all of:
      | Toys | Hounds | Retrievers |
