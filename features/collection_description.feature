Feature: Collection description
  In order to track information about collections
  As a librarian
  I want to be able to edit collection information

  Background:
    Given I am logged in
    And the repository titled 'Sample Repo' has collections with fields:
      | title | start_date | end_date   | published | ongoing | description | access_url              | file_package_summary      | rights_statement | rights_restrictions | notes            |
      | dogs  | 2010-01-01 | 2012-02-02 | true      | true    | Dog stuff   | http://dogs.example.com | Dog files, not so orderly | Dog rights       | Dog restrictions    | Stuff about dogs |
      | cats  | 2011-10-10 |            | false     | true    | Cat stuff   | http://cats.example.com | Cat files, very orderly   | Cat rights       | Cat restrictions    | Stuff about cats |

  Scenario: View a collection
    Given PENDING

  Scenario: Edit a collection
    Given PENDING

  Scenario: Navigate from collection to owning repository
    Given PENDING

  Scenario: Delete a collection from its view page
    Given PENDING