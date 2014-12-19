Feature: Dashboard running processes display
  In order to track batch jobs that I've started
  As a librarian
  I want to have a dashboard display of running processes

  Background:
    Given I am logged in as an admin
    Given the collection with title 'Animals' has child file groups with fields:
      | title  | type              |
      | Dogs  | BitLevelFileGroup |
      | Cats  | BitLevelFileGroup |
      | Gnats | BitLevelFileGroup |
      | Bats  | ExternalFileGroup |

  Scenario: See running virus scans
    Given I am running a virus scan job for the file group titled 'Dogs'
    And I am running a virus scan job for the file group titled 'Cats'
    When I go to the dashboard
    Then I should see the running virus scans table
    And I should see all of:
      | Dogs | Cats |
    And I should not see 'Bats'

  Scenario: See running FITS characterizations
    Given there is a physical cfs directory 'files/dogs'
    And there is a physical cfs directory 'files/cats'
    And the file group titled 'Dogs' has cfs root 'files/dogs'
    And the file group titled 'Cats' has cfs root 'files/cats'
    And I am running a fits job for the file group titled 'Dogs' with 12 files
    And I am running a fits job for the file group titled 'Cats' with 13 files
    When I go to the dashboard
    Then I should see the running fits scans table
    And I should see all of:
      | Dogs | Cats | files/dogs | files/cats | 12 | 13 |
    And I should see none of:
      | Gnats | Bats |

  Scenario: See running initial assessment characterizations
    Given there is a physical cfs directory 'files/dogs'
    And there is a physical cfs directory 'files/cats'
    And the file group titled 'Dogs' has cfs root 'files/dogs'
    And the file group titled 'Cats' has cfs root 'files/cats'
    And I am running an initial assessment job for the file group titled 'Dogs' with 12 files
    And I am running an initial assessment job for the file group titled 'Cats' with 13 files
    When I go to the dashboard
    Then I should see the running initial assessment scans table
    And I should see all of:
      | Dogs | Cats | files/dogs | files/cats | 12 | 13 |
    And I should see none of:
      | Gnats | Bats |

  Scenario: See running ingest processes
    Given I am ingesting 3 file groups with status 'copying'
    And I am ingesting 4 file groups with status 'amazon_backup'
    When I go to the dashboard
    Then I should see the running ingests table
    And I should see 'Copying from staging'
    And I should see 'Backing up to Amazon'

  Scenario: Display failed job count
    Given there are 2 failed delayed jobs
    When I go to the dashboard
    Then I should see '2 delayed jobs have failed'