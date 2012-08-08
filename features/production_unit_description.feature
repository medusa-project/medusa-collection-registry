Feature: Production Unit description
  In order to track units producing digital content
  As a librarian
  I want to create and edit descriptive information about production units

  Background:
    Given I am logged in
    And I have production_units with fields:
      | title    | address_1      | address_2 | city   | state    | zip   | phone_number | email                | url                         | notes                |
      | Scanning | 100 Elm Street | Suite 10  | Urbana | Illinois | 61801 | 555-2345     | scanning@example.com | http://scanning.example.com | They scan stuff here |

  Scenario: Create production unit
    When I go to the new production unit page
    And I fill in fields:
      | Title        | Scraping                    |
      | Address 1    | 200 Oak Street              |
      | Address 2    |                             |
      | City         | Champaign                   |
      | State        | Illinois                    |
      | Zip          | 61820                       |
      | Phone number | 555-1234                    |
      | Email        | scraping@example.com        |
      | URL          | http://scraping.example.com |
      | Notes        | Archiving web content       |
    And I press 'Create Production unit'
    Then A production unit with the title 'Scraping' should exist
    And I should see all of:
      | Scraping | Archiving web content |


  Scenario: View all production unit fields
    When I view the production unit titled 'Scanning'
    Then I should see all production unit fields

  Scenario: Edit all production unit fields
    When I edit the production unit titled 'Scanning'
    Then I should see all production unit fields

  Scenario: View index
    When I go to the production unit index page
    Then I should see a table of production units
    And I should see 'Scanning'

  Scenario: View production unit
    When I view the production unit titled 'Scanning'
    Then I should see all of:
      | Scanning | 100 Elm Street | Suite 10 | Urbana | Illinois | 61801 | 555-2345 | scanning@example.com | http://scanning.example.com | They scan stuff here |

  Scenario: Edit production unit
    When I edit the production unit titled 'Scanning'
    And I fill in fields:
      | Notes | New notes |
    And I press 'Update Production unit'
    Then I should see 'New notes'
    And I should not see 'They scan stuff here'

  Scenario: Delete production unit from view page
    When I view the production unit titled 'Scanning'
    And I click on 'Delete Production Unit'
    Then I should be on the production unit index page
    And I should not see 'Scanning'

  Scenario: Navigate from index page to view page
    When I go to the production unit index page
    And I click on 'Scanning' in the production units table
    Then I should be on the view page for the production unit titled 'Scanning'

  Scenario: Navigate from index page to edit page
    When I go to the production unit index page
    And I click on 'Edit' in the production units table
    Then I should be on the edit page for the production unit titled 'Scanning'

  Scenario: Delete from index page
    When I go to the production unit index page
    And I click on 'Delete' in the production units table
    Then I should be on the production unit index page
    And I should not see 'Scanning'

  Scenario: Create from index page
    When I go to the production unit index page
    And I click on 'New Production Unit'
    Then I should be on the production unit creation page

  Scenario: Navigate from view page to index page
    When I view the production unit titled 'Scanning'
    And I click on 'Back'
    Then I should be on the production unit index page

  Scenario: Navigate from view page to edit page
    When I view the production unit titled 'Scanning'
    And I click on 'Edit'
    Then I should be on the edit page for the production unit titled 'Scanning'

  Scenario: Associate contact with collection
    When I edit the production unit titled 'Scanning'
    And I fill in fields:
      | Adminstrator Net ID | hding2 |
    And I press 'Update Production unit'
    Then I should see 'hding2'
    And There should be a person with net ID 'hding2'
