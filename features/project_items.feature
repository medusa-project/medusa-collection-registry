Feature: Project Items
  In order to manage projects
  As a librarian
  I want to keep track of individual items associated with the projects

  Background:
    Given the project with title 'Scanning' has child items with fields:
      | barcode | bib_id | book_name | title | author | notes       |
      | xyz123  | 54321  | Animal    | Dogs  | Ruthie | My note     |
      | abc789  | 98765  | Animal    | Cats  | CatCat | My cat note |

  Scenario: Project page contains a table of items
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    Then I should see the items table
    And I should see all of:
      | xyz123 | 54321 | Animal | Dogs | Ruthie | abc789 | 98765 | Cats | CatCat | My note | My cat note |

  Scenario: Obtain CSV file of items
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    And I click on 'CSV'
    Then I should receive a file 'items.csv' of type 'text/csv' matching:
      | xyz123 | 54321 | Animal | Dogs | Ruthie | abc789 | 98765 | Cats | CatCat |

  Scenario: View individual item page
    Given I am logged in as a manager
    When I view the item with barcode 'xyz123'
    Then I should see all of:
      | xyz123 | 54321 | Animal | Dogs | Ruthie |

  Scenario: Edit an existing item
    Given I am logged in as a manager
    When I view the item with barcode 'xyz123'
    And I click on 'Edit'
    And I fill in fields:
      | Title  | Toys   |
      | Author | Buster |
    And I click on 'Update'
    Then I should be on the view page for the project with title 'Scanning'
    And I should see all of:
      | Toys | Buster |
    And I should see none of:
      | Dogs | Ruthie |

  Scenario: Create a new item
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

  @javascript
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
  @javascript
  Scenario: Use auto barcode lookup with javascript interface
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    And I click on 'Add Item'
    And I fill in fields:
      | Barcode | 30112017234789 |
    Then I should see all of:
      | Use | Kleinian groups |
    When I click on 'Use'
    And I click on 'Create'
    Then I should see all of:
      | Maskit | Bernard | 1153448 |


