@javascript @search
Feature: Project items mass edit
  In order to update project items rapdily
  As a librarian
  I want to be able to edit certain fields of many items simultaneously

  Background:
    Given the project with title 'Scanning' has child items with fields:
      | barcode        | bib_id | title | author | notes       | call_number | batch   | local_title | item_title |
      | 30012323456789 | 54321  | Dogs  | Ruthie | My note     | XYZ123      | batch_1 |             |            |
      | 30078923456789 | 98765  |       | CatCat | My cat note | ABC789      | batch_2 | Cats        |            |
      | 30045623456789 | 76543  |       | Buster |             |             | batch_1 |             | Bustard    |

  Scenario: Mass edit project items
    Given I am logged in as a project_mgr
    When I view the project with title 'Scanning'
    And I click on 'check_all'
    And I click on 'Mass edit'
    And I fill in item mass edit fields:
      | Batch                 | batch_3 |
      | Reformatting operator | Dee     |
      | Notes                 | My note |
    And I select 'RCAM' from 'Equipment'
    And I check 'mass_action_update_equipment'
    And I click on 'Mass update'
    And I view the project with title 'Scanning'
    Then I should see 'batch_3'
    And I should see none of:
      | batch_1 | batch_2 |
    And the item with fields should exist:
      | barcode        | batch   | reformatting_operator | equipment | notes   |
      | 30012323456789 | batch_3 | Dee                   | RCAM      | My note |
      | 30045623456789 | batch_3 | Dee                   | RCAM      | My note |
      | 30078923456789 | batch_3 | Dee                   | RCAM      | My note |

  Scenario: Mass edit project items doesn't change blank items when unchecked
    Given I am logged in as a project_mgr
    When I view the project with title 'Scanning'
    And I click on 'check_all'
    And I click on 'Mass edit'
    And I fill in item mass edit fields:
      | Reformatting operator | Dee |
    And I click on 'Mass update'
    And I wait 2 seconds
    Then the item with fields should exist:
      | barcode        | batch   | reformatting_operator |
      | 30012323456789 | batch_1 | Dee                   |
      | 30078923456789 | batch_2 | Dee                   |
      | 30045623456789 | batch_1 | Dee                   |
    And I should see all of:
      | batch_1 | batch_2 |

  Scenario: Mass edit project items does change blank items when checked
    Given I am logged in as a project_mgr
    When I view the project with title 'Scanning'
    And I click on 'check_all'
    And I click on 'Mass edit'
    And I fill in item mass edit fields:
      | Reformatting operator | Dee |
      | Batch                 |     |
    And I click on 'Mass update'
    When I view the project with title 'Scanning'
    Then the item with fields should exist:
      | barcode        | batch | reformatting_operator |
      | 30012323456789 |       | Dee                   |
      | 30078923456789 |       | Dee                   |
      | 30045623456789 |       | Dee                   |
    And I should see none of:
      | batch_1 | batch_2 |
