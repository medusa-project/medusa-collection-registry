@javascript @search
Feature: Project Items
  In order to manage projects
  As a librarian
  I want to keep track of individual items associated with the projects

  Background:
    Given the project with title 'Scanning' has child items with fields:
      | barcode | bib_id | title | author | notes       | call_number | batch   | local_title | item_title |
      | xyz123  | 54321  | Dogs  | Ruthie | My note     | XYZ123      | batch_1 |             |            |
      | abc789  | 98765  |       | CatCat | My cat note | ABC789      | batch_2 | Cats        |            |
      | pqr456  | 76543  |       | Buster |             |             | batch_1 |             | Bustard    |

  Scenario: Project page contains a table of items
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    Then I should see the items table
    And I should see all of:
      | xyz123 | Dogs | Ruthie | My note | XYZ123 | batch_1 | 54321 |
    And I should see all of:
      | abc789 | CatCat | My cat note | ABC789 | batch_2 | Cats | 98765 |
    And I should see 'Bustard'

  Scenario: Obtain CSV file of items
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    And I click on 'Export'
    And I click on 'CSV'
    Then I should receive a file 'items.csv' of type 'text/csv' matching:
      | xyz123 | 54321 | Dogs | Ruthie | abc789 | 98765 | Cats | CatCat |

  Scenario: View individual item page
    Given I am logged in as a manager
    When I view the item with barcode 'xyz123'
    Then I should see all of:
      | xyz123 | 54321 | Dogs | Ruthie |

  Scenario: Edit an existing item
    Given I am logged in as a manager
    When I view the item with barcode 'xyz123'
    And I click on 'Edit'
    And I fill in fields:
      | Title              | Toys         |
      | Author             | Buster       |
      | Unique identifier  | abc123       |
      | Creator            | Joebob       |
      | Date               | 1999-10-17   |
      | Rights information | Rights stuff |
    And I select 'RCAM' from 'Equipment'
    And I check 'Foldout present'
    And I check 'Foldout done'
    And I check 'Item done'
    And I click on 'Update'
    Then I should be on the view page for the project with title 'Scanning'
    And I should see all of:
      | Toys | Buster |
    And I should see none of:
      | Dogs | Ruthie |
    When I view the item with barcode 'xyz123'
    Then I should see all of:
      | Toys | Buster | abc123 | RCAM | Joebob | 1999-10-17 | Rights stuff |
    And the item with fields should exist:
      | title | foldout_present | foldout_done | item_done |
      | Toys  | true            | true         | true      |

  Scenario: Create a new item
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    And I click on 'Add Item'
    And I fill in fields:
      | Barcode | pqr456   |
      | Title   | Catch-22 |
      | Author  | Heller   |
    And I click on 'Create and Exit'
    Then I should be on the view page for the project with title 'Scanning'
    And I should see all of:
      | pqr456 | Catch-22 | Heller |

  Scenario: Create a new item with javascript interface
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    And I click on 'Add Item'
    And I fill in fields:
      | Barcode | pqr456   |
      | Title   | Catch-22 |
      | Author  | Heller   |
    And I click on 'Create'
    Then I should be on the view page for the project with title 'Scanning'
    And I should see all of:
      | pqr456 | Catch-22 | Heller |

  #Note that this looks up this item in the live catalog
  Scenario: Use auto barcode lookup with javascript interface
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    And I click on 'Add Item'
    And I fill in fields:
      | Barcode | 30112017234789 |
    Then I should see all of:
      | Use | Kleinian groups |
    When I click on 'Create'
    Then I should see all of:
      | Maskit | Bernard | 1153448 | 515 M379K |

  Scenario: See items from a batch
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    And I click on 'batch_1'
    Then I should see all of:
      | xyz123 | pqr456 |
    And I should see none of:
      | abc789 |

  Scenario: Clone an item from view page
    Given I am logged in as a manager
    When I view the item with title 'Dogs'
    And I click on 'Clone'
    Then I should be on the new item page
    And there should be inputs with values:
      | 54321 | Dogs | Ruthie | XYZ123 | batch_1 |
    And there should not be inputs with values:
      | xyz123 |

  Scenario: Clone an item from edit page
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    And I click on 'Clone'
    Then I should be on the new item page



