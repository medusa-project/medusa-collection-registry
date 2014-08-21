Feature: Institution description
  In order to allow different institutions to manage content repositories
  As a medusa admin
  I want to be able to create and manage institutions

  Background:
    Given every institution with fields exists:
      | name    |
      | UIUC    |
      | SUNY-SB |

  Scenario: As a medusa admin I can see a list of institutions
    Given I am logged in as a medusa admin
    When I go to the institution index page
    Then I should see the institutions table
    And I should see all of:
      | UIUC | SUNY-SB |

  Scenario: As a non-medusa admin I cannot see a list of institutions
    Then deny permission on the institution collection to users for action with redirection:
      | public user      | view_index | authentication |
      | visitor, manager | view_index | unauthorized   |