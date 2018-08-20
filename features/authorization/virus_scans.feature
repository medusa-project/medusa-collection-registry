Feature: Virus scans authorization
  In order to protect the virus scans
  As the system
  I want to enforce proper authorization

  Background:
    Given I clear the cfs root directory
    And the cfs directory 'dogs/images' contains cfs fixture file 'clam.exe'
    And the cfs directory 'dogs/images' contains cfs fixture file 'grass.jpg'
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | title  | type              |
      | images | BitLevelFileGroup |
    And the file group titled 'images' has cfs root 'dogs/images' and delayed jobs are run
    And I am logged in as an admin
    And I view the collection with title 'Dogs'
    And I click on 'Run' in the virus-scan actions and delayed jobs are run

  Scenario: Enforce permissions
    Given I am not logged in
    When I view the most recent virus scan
    Then I should be on the login page