Feature: Static content
  In order to present static information about medusa to the public
  As a librarian
  I want to be able to render and edit static content

  #Note that these tests assume the seeded values of the static pages

  Scenario: Landing page
    Given I am not logged in
    And I visit the static page 'landing'
    Then I should be on the static page 'landing'
    And I should see 'Landing page'

  Scenario: Admin has link to edit static page
    Given I am logged in as an admin
    When I visit the static page 'landing'
    Then I should see 'Edit'

  Scenario: Non admin does not have a link to edit static page
    Given I am logged in as a manager
    When I visit the static page 'landing'
    Then I should not see 'Edit'

  Scenario: Admin edits and updates static page
    Given I am logged in as an admin
    When I visit the static page 'landing'
    And I click on 'Edit'
    And I fill in fields:
      | Page text | New text |
    And I click on 'Update'
    Then I should be on the static page 'landing'
    And I should see 'New text'
    And I should not see 'Landing page'

  Scenario: Non admin cannot update static page
    Then a manager is unauthorized to update the static page 'landing'

  Scenario: Feedback form
    When I visit the static page 'feedback'
    And I fill in fields:
      | Your name          | Joebob Robertson  |
      | Your email address | jbobr@example.com |
      | Your feedback      | Hi there          |
    And I click on 'Send'
    Then 'jbobr@example.com' should receive an email with subject 'Medusa: Feedback confirmation'
    And the feedback address should receive an email with subject /Medusa: Feedback/ matching all of:
      | Joebob Robertson | jbobr@example.com | Hi there |

  Scenario: Deposit files form
    When I visit the static page 'deposit_files'
    And I fill in fields:
      | Your name                 | My name                      |
      | Your email address        | my-email-address@example.com |
      | Your department           | My department                |
      | Collection name           | My collection name           |
      | Current location of files | Location of my files         |
      | Notes                     | My notes                     |
    And I click on 'Send'
    Then 'my-email-address@example.com' should receive an email with subject 'Medusa: Ingest request confirmation'
    And the feedback address should receive an email with subject /Medusa: Ingest request/ matching all of:
      | My name | my-email-address@example.com | My department | My collection name | Location of my files | My notes |

  Scenario: Request training form
    When I visit the static page 'request_training'
    And I fill in fields:
      | Your name          | Namey             |
      | Your email address | namey@example.com |
      | Your department    | Naming            |
      | Suggested date     | 2012-03-04        |
      | List of trainees   | Arpee, Elwah      |
      | Notes              | A flat            |
    And I click on 'Send'
    Then 'namey@example.com' should receive an email with subject 'Medusa: Training request confirmation'
    And the feedback address should receive an email with subject /Medusa: Training request/ matching all of:
      | Namey | namey@example.com | Naming | 2012-03-04 | Arpee | Elwah | A flat |


