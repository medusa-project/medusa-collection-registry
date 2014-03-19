Feature: Dashboard running processes display
  In order to track batch jobs that I've started
  As a librarian
  I want to have a dashboard display of running processes

  Background:
    Given I am logged in as an admin
    Given the collection titled 'Animals' has file groups with fields:
      | name | type              |
      | Dogs | BitLevelFileGroup |
      | Cats | BitLevelFileGroup |
      | Bats | ExternalFileGroup |

  Scenario: See running virus scans
    Given I am running a virus scan job for the file group named 'Dogs'
    And I am running a virus scan job for the file group named 'Cats'
    When I go to the dashboard
    Then I should see a table of running virus scans
    And I should see all of:
      | Dogs | Cats |
    And I should not see 'Bats'

  #This may need a new test for the new cfs stuff. Not sure yet how the
  #FITS will work with that.
  Scenario: See running FITS characterizations
    Given PENDING
    Given the file group named 'Dogs' has cfs root 'files/dogs'
    And the file group named 'Cats' has cfs root 'files/cats'
    And I am running a fits job for the file group named 'Dogs' with 12 files
    And I am running a fits job for the file group named 'Cats' with 13 files
    When I go to the dashboard
    Then I should see a table of running fits scans
    And I should see all of:
      | Dogs | Cats | files/dogs | files/cats | 12 | 13 |
    And I should not see 'Bats'

  Scenario: Display failed job count
    Given PENDING