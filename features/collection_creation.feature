Feature: Collection Management
  In order to make manage collections
  As a librarian
  I want to be able to create and delete collections from repositories

  Background:
    Given I am logged in
    And I have repositories with fields:
      | title       |
      | Sample Repo |
    And the repository titled 'Sample Repo' has collections with fields:
      | title             |
      | Sample Collection |

  Scenario: View collections of a repository
    Given PENDING

  Scenario: Delete collection from a repository
    Given PENDING

  Scenario: Add a collection to a repository
    Given PENDING