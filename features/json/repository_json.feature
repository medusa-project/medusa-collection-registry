Feature: JSON data about repository
  In order to expose repository data to other applications
  As the system
  I want to be able to export JSON describing a repository

  Background:
    Given the repository with title 'Animals' has child collections with fields:
      | title  | id |
      | Dogs   | 1  |
      | Zebras | 2  |

  Scenario: Fetch JSON for a repository for basic auth user
    Given I provide basic authentication
    When I view JSON for the repository with title 'Animals'
    Then the JSON should have "id"
    And the JSON at "title" should be "Animals"
    And the JSON at "collections" should be an array
    And the JSON at "collections" should have 2 entries
    And the JSON at "collections/0/id" should be 1
    And the JSON at "collections/0/path" should be "/collections/1.json"
    And the JSON at "collections/0/title" should be "Dogs"