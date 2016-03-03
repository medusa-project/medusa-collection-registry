Feature: Edit repository admins
  In order to allow repository managers to edit objects controlled by them
  As a medusa administrator
  I want to be able to assign the LDAP group that can administer a repository

  Background:
    Given I have repositories with fields:
      | title   | ldap_admin_domain | ldap_admin_group |
      | Animals | uofi              | Changers         |
      | Plants  | uofi              | Doers            |

  Scenario: Edit admins
    Given I am logged in as an admin
    When I edit repository administration groups
    Then I should see all of:
      | Animals | Plants |

  Scenario: Update admins
    Given I am logged in as an admin
    When I edit repository administration groups
    And I fill in ldap administration info 'uofi\Animal admins' for the repository titled 'Animals'
    And in the ldap administration form for the repository titled 'Animals' I click on 'Update'
    Then the repository titled 'Animals' should be administered by the group 'Animal admins' in the domain 'uofi'

  Scenario: Only medusa admins can edit repository ldap information
    Given I am logged in as a user
    When I edit repository administration groups
    Then I should be redirected to the unauthorized page
    And I should see 'You are not authorized to view the requested page.'

  Scenario: Navigate from repository index to edit ldap groups as an admin
    Given I am logged in as an admin
    When I go to the repository index page
    And I click on 'Edit Repository Admins'
    Then I should be editing repository administration groups
