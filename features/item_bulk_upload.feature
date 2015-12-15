Feature: Item Bulk Upload
  In order to import legacy item data from spreadsheets
  As a librarian
  I want to be able to upload CSV files and have projects make items from the contents
  
  Background: 
    Given the project with title 'dogs' exists
    And I am logged in as a manager

  Scenario: Upload valid item csv
    When I view the project with title 'dogs'
    And I click on 'Upload Items'
    And I attach fixture file 'good-items.txt' to 'Items file'
    And I click on 'Upload' and delayed jobs are run
    Then the project with title 'dogs' should have 5 items
    And 'manager@example.com' should receive an email with subject 'Project items uploaded'

  Scenario: Upload invalid item csv
    When I view the project with title 'dogs'
    And I click on 'Upload Items'
    And I attach fixture file 'bad-items.txt' to 'Items file'
    And I click on 'Upload' and delayed jobs are run
    Then the project with title 'dogs' should have 0 items
    And 'manager@example.com' should receive an email with subject 'Error uploading project items'


