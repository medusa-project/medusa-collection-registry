Feature: File accrual
  In order to add files to already existing file groups
  As a medusa admin
  I want to be able to browse staging and start jobs to copy files from staging to bit storage

  Background:
    Given I clear the cfs root directory
    And the physical cfs directory 'dogs' has the data of bag 'accrual-initial-bag'
    And the collection with title 'Animals' has child file groups with fields:
      | title | type              |
      | Dogs  | BitLevelFileGroup |
      | Cats  | BitLevelFileGroup |
    And the file group titled 'Dogs' has cfs root 'dogs' and delayed jobs are run

  Scenario: There is no accrual button nor form on a file group without cfs directory
    Given I am logged in as a manager
    When I view the bit level file group with title 'Cats'
    Then I should not see 'Add files'
    And I should not see the accrual form and dialog

  Scenario: There is an accrual button and form on a file group with cfs directory
    Given I am logged in as a manager
    When I view the bit level file group with title 'Dogs'
    Then I should see 'Add files'
    And I should see the accrual form and dialog

  Scenario: There is an accrual button and form on a cfs directory
    Given I am logged in as a manager
    When I view the cfs directory for the file group titled 'Dogs' for the path 'pugs'
    Then I should see 'Add files'
    And I should see the accrual form and dialog

  Scenario: There is no accrual button nor form on a file group for a non medusa admin
    Given I am logged in as a visitor
    When I view the bit level file group with title 'Dogs'
    Then I should not see 'Add files'
    And I should not see the accrual form and dialog

  Scenario: There is no accrual button nor form on a cfs directory for a non medusa admin
    Given I am logged in as a visitor
    When I view the cfs directory for the file group titled 'Dogs' for the path 'pugs'
    Then I should not see 'Add files'
    And I should not see the accrual form and dialog

  @javascript
  Scenario: I can navigate the staging storage
    Given I am logged in as an admin
    And the bag 'small-bag' is staged in the root named 'staging-1' at path 'dogs'
    When I view the bit level file group with title 'Dogs'
    And I click link with title 'Run'
    And I click on 'Add files'
    And I click on 'staging-1'
    And I click on 'dogs'
    And within '#add-files-form' I click on 'data'
    Then I should see all of:
      | joe.txt | pete.txt | stuff |
    And I should see none of:
      | more.txt |

  @javascript @current
  Scenario: No conflict accrual, accepted
    When the bag 'accrual-disjoint-bag' is staged in the root named 'staging-1' at path 'dogs'
    And I am logged in as a manager
    And I view the bit level file group with title 'Dogs'
    And I click link with title 'Run'
    And I click on 'Add files'
    And I click on 'staging-1'
    And I click on 'dogs'
    And within '#add-files-form' I click on 'data'
    And I check 'joe.txt'
    And I check 'stuff'
    And I click on 'Ingest'
    Then the cfs directory with path 'dogs' should have an accrual job with 1 files and 1 directory
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should have an accrual job with 1 files and 1 directory
    And the cfs directory with path 'dogs' should have an accrual job with 0 minor conflicts and 0 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending'
    When I go to the dashboard
    And I click on 'Accruals'
    Then I should see all of:
      | Awaiting approval | manager | Animals | Dogs |
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on 'Proceed'
    Then I should not see 'Proceed'
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should have an accrual job with 0 files and 0 directories
    Then the file group titled 'Dogs' should have a cfs directory for the path 'stuff'
    And the file group titled 'Dogs' should have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'pete.txt'
    And there should be 1 amazon backup delayed job
    When amazon backup runs successfully
    Then the file group titled 'Dogs' should have a completed Amazon backup
    And 'manager@example.com' should receive an email with subject 'Amazon backup progress'
    When delayed jobs are run
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual completed'

  @javascript @current
  Scenario: No conflict accrual, aborted
    When the bag 'accrual-disjoint-bag' is staged in the root named 'staging-1' at path 'dogs'
    And I am logged in as a manager
    And I view the bit level file group with title 'Dogs'
    And I click link with title 'Run'
    And I click on 'Add files'
    And I click on 'staging-1'
    And I click on 'dogs'
    And within '#add-files-form' I click on 'data'
    And I check 'joe.txt'
    And I check 'stuff'
    And I click on 'Ingest'
    Then the cfs directory with path 'dogs' should have an accrual job with 1 files and 1 directory
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should have an accrual job with 1 files and 1 directory
    And the cfs directory with path 'dogs' should have an accrual job with 0 minor conflicts and 0 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending'
    When I go to the dashboard
    And I click on 'Accruals'
    Then I should see all of:
      | Awaiting approval | manager | Animals | Dogs |
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on 'Abort'
    Then I should not see 'Abort'
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should not have an accrual job
    And the file group titled 'Dogs' should not have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt'
    And there should be 0 amazon backup delayed jobs
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual aborted'

  @javascript @current
  Scenario: Harmless conflict accrual, accepted
    And the bag 'accrual-duplicate-overlap-bag' is staged in the root named 'staging-1' at path 'dogs'
    And I am logged in as a manager
    And I view the bit level file group with title 'Dogs'
    And I click link with title 'Run'
    And I click on 'Add files'
    And I click on 'staging-1'
    And I click on 'dogs'
    And within '#add-files-form' I click on 'data'
    And I check 'joe.txt'
    And I check 'intro.txt'
    And I check 'stuff'
    And I check 'pugs'
    And I click on 'Ingest'
    Then the cfs directory with path 'dogs' should have an accrual job with 2 files and 2 directories
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should have an accrual job with 2 files and 2 directories
    And the cfs directory with path 'dogs' should have an accrual job with 2 minor conflicts and 0 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    When I go to the dashboard
    And I click on 'Accruals'
    Then I should see all of:
      | Awaiting approval | manager | Animals | Dogs |
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on 'Proceed'
    Then I should not see 'Proceed'
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should have an accrual job with 0 files and 0 directories
    Then the file group titled 'Dogs' should have a cfs directory for the path 'stuff'
    And the file group titled 'Dogs' should have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'joe.txt'
    And there should be 1 amazon backup delayed job
    When amazon backup runs successfully
    Then the file group titled 'Dogs' should have a completed Amazon backup
    And 'manager@example.com' should receive an email with subject 'Amazon backup progress'
    When delayed jobs are run
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual completed'

  @javascript @current
  Scenario: Harmless conflict accrual, aborted
    And the bag 'accrual-duplicate-overlap-bag' is staged in the root named 'staging-1' at path 'dogs'
    And I am logged in as a manager
    And I view the bit level file group with title 'Dogs'
    And I click link with title 'Run'
    And I click on 'Add files'
    And I click on 'staging-1'
    And I click on 'dogs'
    And within '#add-files-form' I click on 'data'
    And I check 'joe.txt'
    And I check 'intro.txt'
    And I check 'stuff'
    And I check 'pugs'
    And I click on 'Ingest'
    Then the cfs directory with path 'dogs' should have an accrual job with 2 files and 2 directories
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should have an accrual job with 2 files and 2 directories
    And the cfs directory with path 'dogs' should have an accrual job with 2 minor conflicts and 0 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    When I go to the dashboard
    And I click on 'Accruals'
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on 'Abort'
    Then I should not see 'Abort'
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should not have an accrual job
    And the file group titled 'Dogs' should not have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt'
    And there should be 0 amazon backup delayed jobs
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual aborted'

  @javascript @current
  Scenario: Changed conflict accrual, aborted by repository manager
    And the bag 'accrual-changed-overlap-bag' is staged in the root named 'staging-1' at path 'dogs'
    And I am logged in as a manager
    And I view the bit level file group with title 'Dogs'
    And I click link with title 'Run'
    And I click on 'Add files'
    And I click on 'staging-1'
    And I click on 'dogs'
    And within '#add-files-form' I click on 'data'
    And I check 'joe.txt'
    And I check 'intro.txt'
    And I check 'stuff'
    And I check 'pugs'
    And I click on 'Ingest'
    Then the cfs directory with path 'dogs' should have an accrual job with 2 files and 2 directories
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should have an accrual job with 2 files and 2 directories
    And the cfs directory with path 'dogs' should have an accrual job with 0 minor conflicts and 2 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    When I go to the dashboard
    And I click on 'Accruals'
    Then I should see all of:
      | Awaiting approval | manager | Animals | Dogs |
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on 'Abort'
    Then I should not see 'Abort'
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should not have an accrual job
    And the file group titled 'Dogs' should not have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt'
    And there should be 0 amazon backup delayed jobs
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual aborted'

  @javascript @current
  Scenario: Changed conflict accrual, aborted by preservation manager
    And the bag 'accrual-changed-overlap-bag' is staged in the root named 'staging-1' at path 'dogs'
    And I am logged in as a manager
    And I view the bit level file group with title 'Dogs'
    And I click link with title 'Run'
    And I click on 'Add files'
    And I click on 'staging-1'
    And I click on 'dogs'
    And within '#add-files-form' I click on 'data'
    And I check 'joe.txt'
    And I check 'intro.txt'
    And I check 'stuff'
    And I check 'pugs'
    And I click on 'Ingest'
    Then the cfs directory with path 'dogs' should have an accrual job with 2 files and 2 directories
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should have an accrual job with 2 files and 2 directories
    And the cfs directory with path 'dogs' should have an accrual job with 0 minor conflicts and 2 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    When I go to the dashboard
    And I click on 'Accruals'
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on 'Proceed'
    When I relogin as an admin
    And I go to the dashboard
    And I click on 'Accruals'
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on 'Abort'
    And I wait 1 seconds
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should not have an accrual job
    And the file group titled 'Dogs' should not have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt'
    And there should be 0 amazon backup delayed jobs
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual aborted'

  @javascript @current
  Scenario: Changed conflict accrual, accepted by preservation manager
    When PENDING
    And the bag 'accrual-changed-overlap-bag' is staged in the root named 'staging-1' at path 'dogs'
    And I am logged in as an admin
    And I view the bit level file group with title 'Dogs'
    And I click link with title 'Run'
    And I click on 'Add files'
    And I click on 'staging-1'
    And I click on 'dogs'
    And within '#add-files-form' I click on 'data'
    And I check 'joe.txt'
    And I check 'intro.txt'
    And I check 'stuff'
    And I check 'pugs'
    And I click on 'Ingest'
    Then the cfs directory with path 'dogs' should have an accrual job with 2 files and 2 directories
    When delayed jobs are run
    Then the cfs directory with path 'dogs' should have an accrual job with 2 files and 2 directories
    And the cfs directory with path 'dogs' should have an accrual job with 0 minor conflicts and 2 serious conflicts
    And 'admin@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    When I go to the dashboard
    And I click on 'Accruals'
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on 'Proceed'
    And I go to the dashboard
    And I click on 'Accruals'
    And within '#accruals' I click on 'Actions'
    And within '#accruals' I click on 'Proceed'
    And I wait 1 seconds
    When delayed jobs are run
    #New files should be ingested
    #Old files should have been overwritten
    #Amazon backup should have happened

  @javascript @current
  Scenario: Harmless conflict accrual, view report
    When PENDING

  @javascript @current
  Scenario: Changed conflict accrual, view report
    When PENDING



