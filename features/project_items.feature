Feature: Project Items
  In order to manage projects
  As a librarian
  I want to keep track of individual items associated with the projects

  Background:
    Given the project with title 'Scanning' has child items with fields:
      | barcode | bib_id | book_name | title | author |
      | xyz123  | 54321  | Animal    | Dogs  | Ruthie |
      | abc789  | 98765  | Animal    | Cats  | CatCat |

  Scenario: Project page contains a table of items
    Given I am logged in as a manager
    When I view the project with title 'Scanning'
    Then I should see the items table
    And I should see all of:
      | xyz123 | 54321 | Animal | Dogs | Ruthie | abc789 | 98765 | Cats | CatCat |

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
    When I edit the item with barcode 'xyz123'
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


