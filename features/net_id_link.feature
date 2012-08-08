Feature: Net ID links
  In order to manage preservatin
  As a librarian
  I want to be able to get information about UIUC actors on the collections

  Background:
    Given I am logged in
    And the repository titled 'Animals' is managed by 'hding2'

  Scenario: Link repository manager
    When I view the repository titled 'Animals'
    Then There should be an external link 'hding2' to the UIUC Net ID search
