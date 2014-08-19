Feature: Amazon backup
  In order to have off site backups
  As an administrator
  I want to be able to bag cfs directories and send them to Amazon

  Background:
    Given I clear the cfs root directory
    And the collection with title 'Animals' has child file groups with fields:
      | name | type              |
      | Dogs | BitLevelFileGroup |
      | Cats | BitLevelFileGroup |
    And there is a physical cfs directory 'dogs'
    And there is a physical cfs directory 'cats'
    And the file group named 'Dogs' has cfs root 'dogs'
    And the file group named 'Cats' has cfs root 'cats' and delayed jobs are run

  Scenario: Create bag from a cfs directory
    Given the physical cfs directory 'dogs' has the data of bag 'small-bag'
    When I create Amazon bags for the cfs directory with path 'dogs'
    Then the cfs directory with path 'dogs' should have 1 amazon backup
    And there should be 1 Amazon backup bag
    And there should be 1 Amazon backup manifest
    And all the data of bag 'small-bag' should be in some Amazon backup bag

  Scenario: Create bags from a large cfs directory
    Given the physical cfs directory 'dogs' has the data of bag 'big-bag'
    When I create Amazon bags for the cfs directory with path 'dogs'
    Then the cfs directory with path 'dogs' should have 1 amazon backup
    And there should be 2 Amazon backup bags
    And there should be 2 Amazon backup manifests
    And all the data of bag 'big-bag' should be in some Amazon backup bag

  Scenario: Schedule amazon backup of a bit level file group
    Given I am logged in as a medusa admin
    When I view the file group with name 'Dogs'
    And I click on 'Create backup'
    Then there should be 1 amazon backup delayed job

  Scenario: Bulk schedule amazon backup of bit level file groups
    Given I am logged in as a medusa admin
    When I go to the dashboard
    And I check all amazon backup checkboxes
    And I click on 'Create Backups'
    Then there should be 2 amazon backup delayed jobs

  Scenario: Amazon backup is restricted to medusa admins
    Then deny object permission on the bit level file group with name 'Dogs' to users for action with redirection:
      | public user      | create_amazon_backup(post) | authentication |
      | visitor, manager | create_amazon_backup(post) | unauthorized   |

  Scenario: Bulk amazon backup is restricted to medusa admins
    When deny permission on the bit level file group collection to users for action with redirection:
      | public user      | bulk_amazon_backup via post | authentication |
      | visitor, manager | bulk_amazon_backup via post | unauthorized   |

