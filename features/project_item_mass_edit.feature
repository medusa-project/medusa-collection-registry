@javascript @search
Feature: Project items mass edit
  In order to update project items rapdily
  As a librarian
  I want to be able to edit certain fields of many items simultaneously

  Background:
    Given the project with title 'Scanning' has child items with fields:
      | barcode | bib_id | title | author | notes       | call_number | batch   | local_title | item_title |
      | xyz123  | 54321  | Dogs  | Ruthie | My note     | XYZ123      | batch_1 |             |            |
      | abc789  | 98765  |       | CatCat | My cat note | ABC789      | batch_2 | Cats        |            |
      | pqr456  | 76543  |       | Buster |             |             | batch_1 |             | Bustard    |

  #@selenium
  Scenario: Mass edit project items
    Given I am logged in as an admin
    When I view the project with title 'Scanning'
    And I click on 'check_all'
    And I click on 'Mass edit'
    And I fill in item mass edit fields:
      | Batch                 | batch_3 |
      | Reformatting operator | Dee     |
    And I select 'RCAM' from 'Equipment'
    And I check 'mass_action_update_equipment'
    And I click on 'Mass update'
    And I wait 2 seconds
    Then the item with fields should exist:
      | barcode | batch   | reformatting_operator | equipment |
      | xyz123  | batch_3 | Dee                   | RCAM      |
      | pqr456  | batch_3 | Dee                   | RCAM      |
      | abc789  | batch_3 | Dee                   | RCAM      |
    And I should see 'batch_3'
    And I should see none of:
      | batch_1 | batch_2 |

  Scenario: Mass edit project items doesn't change unchecked items
    Given I am logged in as an admin
    When I view the project with title 'Scanning'
    And I click on 'check_all'
    And I click on 'Mass edit'
    And I fill in item mass edit fields:
      | Reformatting operator | Dee |
    And I click on 'Mass update'
    And I wait 2 seconds
    Then the item with fields should exist:
      | barcode | batch   | reformatting_operator |
      | xyz123  | batch_1 | Dee                   |
      | abc789  | batch_2 | Dee                   |
      | pqr456  | batch_1 | Dee                   |
    And I should see all of:
      | batch_1 | batch_2 |
