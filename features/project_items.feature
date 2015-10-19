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

  Scenario: View individual item page
    Given I am logged in as a manager
    When I view the item with barcode 'xyz123'
    Then I should see all of:
      | xyz123 | 54321 | Animal | Dogs | Ruthie |


