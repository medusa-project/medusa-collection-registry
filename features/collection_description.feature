Feature: Collection description
  In order to track information about collections
  As a librarian
  I want to be able to edit collection information

  Background:
    Given I am logged in as an admin
    And the repository with title 'Sample Repo' has child collections with fields:
      | title | description                               | private_description                          | access_url              | notes                                       | external_id      |
      | dogs  | Dog stuff                                 | private dog info                             | http://dogs.example.com | Stuff about dogs                            | external-dogs-id |
      | cats  | Cat stuff. http://description.example.com | private cat info. http://private.example.com | http://cats.example.com | Stuff about cats. https://notes.example.com |                  |

  Scenario: Change repository of a collection
    Given the repository with title 'Plays' has child collections with fields:
      | title |
      | Proof |
    When I edit the collection with title 'cats'
    And I select 'Plays' from 'Repository'
    And I click on 'Update'
    Then the repository with title 'Plays' should have 1 collection with title 'cats'

  Scenario: View a collection
    When I view the collection with title 'dogs'
    Then I should see all of:
      | Dog stuff | private dog info | http://dogs.example.com |
    And I should see all of:
      | Stuff about dogs | external-dogs-id |

  Scenario: View a collection as a manager
    Given I relogin as a manager
    When I view the collection with title 'dogs'
    Then I should be on the view page for the collection with title 'dogs'

  Scenario: View a collection as a user
    Given I relogin as a user
    When I view the collection with title 'dogs'
    Then I should be on the view page for the collection with title 'dogs'

  Scenario: Edit a collection
    When I edit the collection with title 'dogs'
    And I fill in fields:
      | Description             | Puppy stuff                    |
      | Private description     | Internal puppy stuff           |
      | External ID             | external-puppy-id              |
      | Representative image    | my_image_url                   |
      | Representative item     | my_item_url                    |
      | Physical collection URL | http://physical.collection.url |
    And I check 'Publish'
    And I press 'Update'
    Then I should be on the view page for the collection with title 'dogs'
    And I should see all of:
      | Puppy stuff | Internal puppy stuff | external-puppy-id | my_image_url | my_item_url | http://physical.collection.url |
    And I should see none of:
      | Dog stuff | external-dogs-id |

  Scenario: Edit a collection as a manager
    When I relogin as a manager
    And I edit the collection with title 'dogs'
    And I fill in fields:
      | Description         | Puppy stuff          |
      | Private description | Internal puppy stuff |
    And I press 'Update'
    Then I should be on the view page for the collection with title 'dogs'
    And I should see 'Puppy stuff'
    And I should see 'Internal puppy stuff'
    And I should not see 'Dog stuff'

  Scenario: Navigate from collection view page to its edit page
    When I view the collection with title 'dogs'
    And I click on 'Edit'
    Then I should be on the edit page for the collection with title 'dogs'

  Scenario: Delete a collection from its edit page
    When I edit the collection with title 'dogs'
    And I click on 'Delete'
    Then I should be on the view page for the repository with title 'Sample Repo'
    And I should not see 'dogs'

  Scenario: Create a new collection
    When I start a new collection for the repository titled 'Sample Repo'
    And I fill in fields:
      | Title               | reptiles      |
      | Description         | Reptile stuff |
      | Private description | Snake farm    |
    And I press 'Create'
    Then I should be on the view page for the collection with title 'reptiles'
    And I should see 'Reptile stuff'
    And I should see 'Snake farm'
    And The collection with title 'reptiles' should have a valid uuid
    And the repository with title 'Sample Repo' should have 1 collection with title 'reptiles'

  Scenario: Create a new collection as a manager
    And I relogin as a manager
    When I start a new collection for the repository titled 'Sample Repo'
    And I fill in fields:
      | Title               | reptiles      |
      | Description         | Reptile stuff |
      | Private description | Snake farm    |
    And I press 'Create'
    Then I should be on the view page for the collection with title 'reptiles'
    And I should see 'Reptile stuff'
    And I should see 'Snake farm'
    And The collection with title 'reptiles' should have a valid uuid
    And the repository with title 'Sample Repo' should have 1 collection with title 'reptiles'

  Scenario: Index of all collections
    When I go to the collection index page
    Then I should be on the collection index page
    And I should see the collections table
    And I should see 'external-dogs-id'

  Scenario: Index of all collections as a manager
    Given I relogin as a manager
    When I go to the collection index page
    Then I should be on the collection index page

  Scenario: Index of all collections as a user
    Given I relogin as a user
    When I go to the collection index page
    Then I should be on the collection index page

  Scenario: Get CSV dump of all collections
    When I go to the collection index page
    And I click on 'CSV'
    Then I should receive a file 'collections.csv' of type 'text/csv' matching:
      | Dog stuff | Stuff about dogs | external-dogs-id | Cat stuff | Stuff about cats. https://notes.example.com | Sample Repo |

  Scenario: Get CSV dump of a repository's collections
    When I view the repository with title 'Sample Repo'
    And I click on 'CSV'
    Then I should receive a file 'collections.csv' of type 'text/csv' matching:
      | Dog stuff | Stuff about dogs | external-dogs-id | Cat stuff | Stuff about cats. https://notes.example.com | Sample Repo |

  Scenario: Navigate index to collection
    When I go to the collection index page
    And I click on 'dogs'
    Then I should be on the view page for the collection with title 'dogs'

  Scenario: Navigate index to repository
    When I go to the collection index page
    And I click on 'Sample Repo'
    Then I should be on the view page for the repository with title 'Sample Repo'

  Scenario: Associate contact with collection
    When I edit the collection with title 'dogs'
    And I fill in fields:
      | Contact Person Email | hding2@example.com |
    And I press 'Update'
    Then I should see 'hding2@example.com'
    And a person with email 'hding2@example.com' should exist

  Scenario: Auto link links from description fields and notes
    When I view the collection with title 'cats'
    Then I should see a link to 'http://private.example.com'
    Then I should see a link to 'http://description.example.com'
    Then I should see a link to 'https://notes.example.com'
