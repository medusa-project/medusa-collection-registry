Feature: Static content
  In order to present static information about medusa to the public
  As a librarian
  I want to be able to render and edit static content

  Scenario: Landing page
    Given I am not logged in
    And I visit the static page 'landing'
    Then I should be on the static page 'landing'
    And I should see 'Landing page'

  Scenario: Admin has link to edit static page
    Given I am logged in as an admin
    When PENDING

  Scenario: Non admin does not have a link to edit static page
    When PENDING

  Scenario: Admin edits and updates static page
    Given I am logged in as an admin
    When PENDING

  Scenario: Non admin tries to update static page
    When PENDING
