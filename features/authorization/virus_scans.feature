Feature: Virus scans authorization
  In order to protect the virus scans
  As the system
  I want to enforce proper authorization

  Background:
    Given I clear the cfs root directory
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | name   | type              |
      | images | BitLevelFileGroup |
    And the file group named 'images' has cfs root 'dogs/images'
    And the cfs directory 'dogs/images' contains cfs fixture file 'clam.exe'
    And the cfs directory 'dogs/images' contains cfs fixture file 'grass.jpg'
    And I am logged in as an admin
    And I view the collection titled 'Dogs'
    And I click on 'Run' in the virus-scan actions

  Scenario:
    Given I am not logged in
    When I view the most recent virus scan
    Then I should be on the login page