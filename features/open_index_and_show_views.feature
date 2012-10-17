Feature: Open index and show
  In order to share information with the world
  As a librarian
  I want the index and show views of certain controllers to be unprotected by auth/auth

  Background:
    Given I am not logged in

  Scenario: View Repository Index
    When I go to the repository index page
    Then I should be on the repository index page

  Scenario: View Repository
    Given the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    When I view the repository titled 'Animals'
    Then I should be on the view page for the repository titled 'Animals'

  Scenario: View Collection Index
    When I go to the collection index page
    Then I should be on the collection index page

  Scenario: View Collection
    Given the repository titled 'Animals' has collections with fields:
          | title |
          | Dogs  |
    When I view the collection titled 'Dogs'
    Then I should be on the view page for the collection titled 'Dogs'

  Scenario: View Producer Index
    When I go to the producer index page
    Then I should be on the producer index page

  Scenario: View Producer
    Given I have producers with fields:
          | title    |
          | Scanning |
    When I view the producer titled 'Scanning'
    Then I should be on the view page for the producer titled 'Scanning'

  Scenario: View Access System index
    When I go to the access system index page
    Then I should be on the access system index page

  Scenario: View Access System
    Given The access system named 'DSpace' exists
    When I view the access system named 'DSpace'
    Then I should be on the view page for the access system named 'DSpace'
