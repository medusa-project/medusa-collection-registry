Feature: Static content
  In order to present static information about medusa to the public
  As a librarian
  I want to be able to render static content

  Scenario: Landing page
    Given I am not logged in
    And I visit the static page 'landing'
    Then I should be on the static page 'landing'
