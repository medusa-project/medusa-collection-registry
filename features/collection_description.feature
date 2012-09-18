Feature: Collection description
  In order to track information about collections
  As a librarian
  I want to be able to edit collection information

  Background:
    Given I am logged in as an admin
    And the repository titled 'Sample Repo' has collections with fields:
      | title | start_date | end_date   | published | ongoing | description | private_description | access_url              | file_package_summary      | rights_statement | rights_restrictions | notes            |
      | dogs  | 2010-01-01 | 2012-02-02 | true      | true    | Dog stuff   | private dog info    | http://dogs.example.com | Dog files, not so orderly | Dog rights       | Dog restrictions    | Stuff about dogs |
      | cats  | 2011-10-10 |            | false     | true    | Cat stuff. http://description.example.com   | private cat info. http://private.example.com    | http://cats.example.com | Cat files, very orderly   | Cat rights       | Cat restrictions    | Stuff about cats. https://notes.example.com |

  Scenario: Change repository of a collection
    Given the repository titled 'Plays' has collections with fields:
      | title |
      | Proof |
    When I edit the collection titled 'cats'
    And I select repository 'Plays'
    And I click on 'Update Collection'
    Then the repository titled 'Plays' should have a collection titled 'cats'

  Scenario: View a collection
    When I view the collection titled 'dogs'
    Then I should see '2010-01-01'
    And I should see '2012-02-02'
    And I should see 'Dog stuff'
    And I should see 'private dog info'
    And I should see 'http://dogs.example.com'
    And I should see 'Dog files, not so orderly'
    And I should see 'Dog rights'
    And I should see 'Dog restrictions'
    And I should see 'Stuff about dogs'

  Scenario: Edit a collection
    When I edit the collection titled 'dogs'
    And I fill in fields:
      | Description         | Puppy stuff          |
      | Private description | Internal puppy stuff |
    And I press 'Update Collection'
    Then I should be on the view page for the collection titled 'dogs'
    And I should see 'Puppy stuff'
    And I should see 'Internal puppy stuff'
    And I should not see 'Dog stuff'

  Scenario: Navigate from collection view page to its edit page
    When I view the collection titled 'dogs'
    And I click on 'Edit'
    Then I should be on the edit page for the collection titled 'dogs'

  Scenario: Delete a collection from its view page
    When I view the collection titled 'dogs'
    And I click on 'Delete'
    Then I should be on the view page for the repository titled 'Sample Repo'
    And I should not see 'dogs'

  Scenario: Create a new collection
    When I start a new collection for the repository titled 'Sample Repo'
    And I fill in fields:
      | Title               | reptiles      |
      | Description         | Reptile stuff |
      | Private description | Snake farm    |
    And I press 'Create Collection'
    Then I should be on the view page for the collection titled 'reptiles'
    And I should see 'Reptile stuff'
    And I should see 'Snake farm'
    And The collection titled 'reptiles' should have a valid UUID
    And the repository titled 'Sample Repo' should have a collection titled 'reptiles'

  Scenario: Index of all collections
    When I go to the collection index page
    Then I should be on the collection index page
    And I should see a list of all collections

  Scenario: Navigate index to collection
    When I go to the collection index page
    And I click on 'dogs'
    Then I should be on the view page for the collection titled 'dogs'

  Scenario: Navigate index to repository
    When I go to the collection index page
    And I click on 'Sample Repo'
    Then I should be on the view page for the repository titled 'Sample Repo'

  Scenario: Associate contact with collection
    When I edit the collection titled 'dogs'
    And I fill in fields:
      | Contact Person Net ID | hding2 |
    And I press 'Update Collection'
    Then I should see 'hding2'
    And There should be a person with net ID 'hding2'

  Scenario: Auto link links from description fields and notes
    When I view the collection titled 'cats'
    Then I should see a link to 'http://private.example.com'
    Then I should see a link to 'http://description.example.com'
    Then I should see a link to 'https://notes.example.com'