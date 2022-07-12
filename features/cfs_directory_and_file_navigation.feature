Feature: Main storage integration
  In order to temporarily preserve and work with files before ingest
  As a librarian
  I want to be able to work with a main storage share

  Background:
    Given the main storage has a key 'dogs/intro.txt' with contents 'anything'
    And the main storage has a key 'dogs/pugs/document.doc' with contents 'anything'
    And the main storage has a key 'dogs/pugs/description.txt' with contents 'anything'
    And the main storage has a key 'dogs/pugs/toys/something.txt' with contents 'anything'
    And the collection with title 'Animals' has child file groups with fields:
      | title | type              |
      | Dogs  | BitLevelFileGroup |
    And the file group titled 'Dogs' has cfs root 'dogs' and delayed jobs are run

  @javascript @search
  Scenario: View CFS directory as an admin
    Given I am logged in as an admin
    And the uuid of the cfs directory with path 'pugs' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    When I view the cfs directory for the file group titled 'Dogs' for the path 'pugs'
    Then I should see all of:
      | toys | 3da0fae0-e3fa-012f-ac10-005056b22849-8 |
    When I click on 'Files'
    Then I should see all of:
      | document.doc | description.txt |

  @javascript @search
  Scenario: View CFS directory as a manager
    Given I am logged in as a manager
    When I view the cfs directory for the file group titled 'Dogs' for the path '.'
    Then I should see 'pugs'
    When I click on 'Files'
    Then I should see 'intro.txt'

  @javascript @search
  Scenario: View CFS directory as a user
    Given I am logged in as a user
    When I view the cfs directory for the file group titled 'Dogs' for the path '.'
    Then I should see 'pugs'
    When I click on 'Files'
    Then I should see 'intro.txt'

  Scenario: View CFS directory as a public user
    Given I am not logged in
    When I view the cfs directory for the file group titled 'Dogs' for the path '.'
    Then I should be on the login page

# TODO figure out what this is supposed to test

#  @javascript @search
#  Scenario: Navigate CFS directory down
#    Given I am logged in as an admin
#    When I view the cfs directory for the file group titled 'Dogs' for the path '.'
#    And I click on 'pugs'
#    Then I should be viewing the cfs directory for the file group titled 'Dogs' for the path 'pugs'
#
#  Scenario: Navigate CFS directory up
#    Given I am logged in as an admin
#    When I view the cfs directory for the file group titled 'Dogs' for the path 'pugs/toys'
#    And I click on 'pugs'
#    Then I should be viewing the cfs directory for the file group titled 'Dogs' for the path 'pugs'
#
#  Scenario: View a file as an admin
#    Given I am logged in as an admin
#    When I view the cfs file for the file group titled 'Dogs' for the path 'intro.txt'
#    Then I should be viewing the cfs file for the file group titled 'Dogs' for the path 'intro.txt'
#    And I should see 'intro.txt'
#
#  Scenario: View a file as a manager
#    Given I am logged in as a manager
#    When I view the cfs file for the file group titled 'Dogs' for the path 'intro.txt'
#    Then I should be viewing the cfs file for the file group titled 'Dogs' for the path 'intro.txt'
#
#  Scenario: View a file as a user
#    Given I am logged in as a user
#    When I view the cfs file for the file group titled 'Dogs' for the path 'intro.txt'
#    Then I should be viewing the cfs file for the file group titled 'Dogs' for the path 'intro.txt'
#
#  Scenario: View a file as a public user
#    Given I am not logged in
#    When I view the cfs file for the file group titled 'Dogs' for the path 'intro.txt'
#    Then I should be on the login page


