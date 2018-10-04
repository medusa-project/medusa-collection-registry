Feature: Producer Report
  In order to track accumulation of content by a producer
  As a librarian
  I want to get a report emailed to me

  Background:
    Given every producer with fields exists:
      | title    |
      | Scanning |

  Scenario: Create a report request
    Given I am logged in as an admin
    When I view the producer with title 'Scanning'
    And I click on 'Report'
    Then there should be 1 delayed job
    And I should see 'Your report will be emailed to you shortly.'

  Scenario: Fullfill a report request
    Given there is a producer report job for user 'admin@example.com' and the producer with title 'Scanning'
    When I perform producer report jobs
    Then 'admin@example.com' should receive an email with subject 'Medusa: Producer Report' containing all of:
      | Scanning |
    And 'admin@example.com' should receive an email with attachment 'report.csv'