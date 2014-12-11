Feature: Title uniqueness and presence
  In order to track certain objects in an orderly fashion
  As a librarian
  I want duplicate titles to be forbidden

  Background:
    Given I am logged in as an admin
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the repository with title 'Plants' has child collections with fields:
      | title |
      | Roses |
    And every producer with fields exists:
      | title    |
      | Scanning |

  Scenario: Prevent duplicate repository titles
    When I go to the new repository page
    And I fill in fields:
      | Title | Animals |
    And I press 'Create Repository'
    Then I should see 'has already been taken'

  Scenario: Prevent blank repository titles
    When I go to the new repository page
    And I press 'Create Repository'
    Then I should see 'can't be blank'

  Scenario: Prevent duplicate producer titles
    When I go to the new producer page
    And I fill in fields:
      | Title | Scanning |
    And I press 'Create Producer'
    Then I should see 'has already been taken'

  Scenario: Prevent blank producer titles
    When I go to the new producer page
    And I press 'Create Producer'
    Then I should see 'can't be blank'

  Scenario: Prevent duplicate collection titles under same repository
    When I start a new collection for the repository titled 'Animals'
    And I fill in fields:
      | Title | Dogs |
    And I press 'Create'
    Then I should see 'has already been taken'

  Scenario: Allow duplicate collection titles under different repositories
    When I start a new collection for the repository titled 'Animals'
    And I fill in fields:
      | Title | Roses |
    And I press 'Create'
    Then I should not see 'has already been taken'
    And the repository with title 'Animals' should have 1 collection with title 'Roses'

  Scenario: Prevent blank collection titles
    When I start a new collection for the repository titled 'Animals'
    And I press 'Create'
    Then I should see 'can't be blank'