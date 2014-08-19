Feature: Producer description
  In order to track units producing digital content
  As a librarian
  I want to create and edit descriptive information about producers

  Background:
    Given every producer with fields exists:
      | title    | address_1      | address_2 | city   | state    | zip   | phone_number | email                | url                         | notes                |
      | Scanning | 100 Elm Street | Suite 10  | Urbana | Illinois | 61801 | 555-2345     | scanning@example.com | http://scanning.example.com | They scan stuff here. http://notes.example.com |

  Scenario: Create producer
    Given I am logged in as an admin
    When I go to the new producer page
    And I fill in fields:
      | Title        | Scraping                                           |
      | Address 1    | 200 Oak Street                                     |
      | Address 2    |                                                    |
      | City         | Champaign                                          |
      | State        | Illinois                                           |
      | Zip          | 61820                                              |
      | Phone Number | 555-1234                                           |
      | Email        | scraping@example.com                               |
      | URL          | http://scraping.example.com                        |
      | Notes        | Archiving web content |
    And I press 'Create Producer'
    Then a producer with title 'Scraping' should exist
    And I should see all of:
      | Scraping | Archiving web content |

  Scenario: View all producer fields as admin
    Given I am logged in as an admin
    When I view the producer with title 'Scanning'
    Then I should see all producer fields

  Scenario: View all producer fields as manager
    Given I am logged in as a manager
    When I view the producer with title 'Scanning'
    Then I should see all producer fields

  Scenario: View all producer fields as visitor
    Given I am logged in as a visitor
    When I view the producer with title 'Scanning'
    Then I should see all producer fields

  Scenario: Edit all producer fields
    Given I am logged in as an admin
    When I edit the producer with title 'Scanning'
    Then I should see all producer fields

  Scenario: View index as admin
    Given I am logged in as an admin
    When I go to the producer index page
    Then I should see the producers table
    And I should see 'Scanning'
    And I should see the producer definition

  Scenario: View index as manager
    Given I am logged in as a manager
    When I go to the producer index page
    Then I should see the producers table

  Scenario: View index as a visitor
    Given I am logged in as a visitor
    When I go to the producer index page
    Then I should see the producers table

  Scenario: View producer
    Given I am logged in as an admin
    When I view the producer with title 'Scanning'
    Then I should see all of:
      | Scanning | 100 Elm Street | Suite 10 | Urbana | Illinois | 61801 | 555-2345 | scanning@example.com | http://scanning.example.com | They scan stuff here |

  Scenario: Edit producer
    Given I am logged in as an admin
    When I edit the producer with title 'Scanning'
    And I fill in fields:
      | Notes | New notes |
    And I press 'Update Producer'
    Then I should see 'New notes'
    And I should not see 'They scan stuff here'

  Scenario: Edit producer shows definition
    Given I am logged in as an admin
    When I edit the producer with title 'Scanning'
    Then I should see the producer definition

  Scenario: Delete producer from view page
    Given I am logged in as an admin
    When I view the producer with title 'Scanning'
    And I click on 'Delete Producer'
    Then I should be on the producer index page
    And I should not see 'Scanning'

  Scenario: Navigate from index page to view page
    Given I am logged in as an admin
    When I go to the producer index page
    And I click on 'Scanning' in the producers table
    Then I should be on the view page for the producer with title 'Scanning'

  Scenario: Navigate from index page to edit page
    Given I am logged in as an admin
    When I go to the producer index page
    And I click on 'Edit' in the producers table
    Then I should be on the edit page for the producer with title 'Scanning'

  Scenario: Delete from index page
    Given I am logged in as an admin
    When I go to the producer index page
    And I click on 'Delete' in the producers table
    Then I should be on the producer index page
    And I should not see 'Scanning'

  Scenario: Create from index page
    Given I am logged in as an admin
    When I go to the producer index page
    And I click on 'New Producer'
    Then I should be on the new producer page
    And I should see the producer definition

  Scenario: Navigate from view page to index page
    Given I am logged in as an admin
    When I view the producer with title 'Scanning'
    And I click on 'Back'
    Then I should be on the producer index page

  Scenario: Navigate from view page to edit page
    Given I am logged in as an admin
    When I view the producer with title 'Scanning'
    And I click on 'Edit'
    Then I should be on the edit page for the producer with title 'Scanning'

  Scenario: Associate contact with collection
    Given I am logged in as an admin
    When I edit the producer with title 'Scanning'
    And I fill in fields:
      | Administrator Email | hding2@example.com |
    And I press 'Update Producer'
    Then I should see 'hding2@example.com'
    And There should be a person with email 'hding2@example.com'

  Scenario: Auto link from the notes text
    Given I am logged in as an admin
    When I view the producer with title 'Scanning'
    Then I should see a link to 'http://notes.example.com'
