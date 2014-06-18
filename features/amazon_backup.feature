Feature: Amazon backup
  In order to have off site backups
  As an administrator
  I want to be able to bag cfs directories and send them to Amazon

  Background:
    Given I clear the cfs root directory
    And the collection titled 'Animals' has file groups with fields:
      | name | type              |
      | Dogs | BitLevelFileGroup |
    And there is a physical cfs directory 'dogs'
    And the file group named 'Dogs' has cfs root 'dogs'

  Scenario: Create bag from a cfs directory
    Given the physical cfs directory 'dogs' has the data of bag 'small-bag'
    When I create Amazon bags for the cfs directory with path 'dogs'
    Then the cfs directory with path 'dogs' should have 1 Amazon backup
    And there should be 1 Amazon backup bag
    And there should be 1 Amazon backup manifest
    And all the data of bag 'small-bag' should be in some Amazon backup bag

  Scenario: Create bags from a large cfs directory
    Given the physical cfs directory 'dogs' has the data of bag 'big-bag'
    When I create Amazon bags for the cfs directory with path 'dogs'
    Then the cfs directory with path 'dogs' should have 1 Amazon backup
    And there should be 2 Amazon backup bags
    And there should be 2 Amazon backup manifests
    And all the data of bag 'big-bag' should be in some Amazon backup bag
