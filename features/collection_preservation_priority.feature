Feature: Preservation Priority
  In order to make preservation decisions
  As a librarian
  I want to be able to set different preservation priorities on a collection by collection basis

  Background:
    Given I am logged in as an admin
    And There is a collection titled 'Dogs'
    And The collection titled 'Dogs' has preservation priority 'low'

  Scenario: Edit and View preservation priority
    When I edit the collection with title 'Dogs'
    And I select 'urgent' from 'Preservation priority'
    And I click on 'Update Collection'
    Then I should see 'urgent'
    And The collection titled 'Dogs' should have preservation priority 'urgent'

  Scenario: See preservation priority in collection index
    When I go to the collection index page
    Then I should see 'Preservation Priority'
    And I should see 'low'

  Scenario: See preservation priority in repository show page
    When I view the repository having a collection titled 'Dogs'
    Then I should see 'Preservation Priority'
    And I should see 'low'
