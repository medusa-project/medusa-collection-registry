Feature: Bit Level File Group virus check
  In order to enhance security
  As a librarian
  I want to be able to scan bit level file groups for viruses

  Background:
    Given I am logged in as an admin
    And I clear the cfs root directory
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | name   | type              |
      | images | BitLevelFileGroup |
    And the file group named 'images' has cfs root 'dogs/images'
    And the cfs directory 'dogs/images' contains cfs fixture file 'clam.exe'
    And the cfs directory 'dogs/images' contains cfs fixture file 'grass.jpg'

  Scenario: Run a virus check
    When I view the collection titled 'Dogs'
    And I click on 'Run' in the virus-scan actions
    Then the file group named 'images' should have 1 virus scan attached
    And the cfs file 'dogs/images/clam.exe' should have 1 red flags

  Scenario: Run a virus check as a manager
    Given I relogin as a manager
    When I view the collection titled 'Dogs'
    And I click on 'Run' in the virus-scan actions
    Then the file group named 'images' should have 1 virus scan attached
    And the cfs file 'dogs/images/clam.exe' should have 1 red flags

  Scenario: View results of a virus check
    When I view the collection titled 'Dogs'
    And I click on 'Run' in the virus-scan actions
    And I view the collection titled 'Dogs'
    And I click on 'View Latest' in the virus-scan actions
    Then I should see 'images'
    And I should see all of:
      | Infected files: 1 | Scanned files: 2 | dogs/images/clam.exe: ClamAV-Test-File FOUND |
