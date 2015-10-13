Feature: File accrual
  In order to add files to already existing file groups
  As a medusa admin
  I want to be able to browse staging and start jobs to copy files from staging to bit storage

  #Note that these are long tests with Javascript involved and because of the way
  #that works with capybara they can be a bit finicky. There may be timing/db issues
  #that wouldn't appear in the real system. E.g there are some sleeps in the tests
  #that have no systematic reason; it just appears that at these points the test
  #may bog down and need to wait because the javascript engine and Rails are
  #off a little bit. Some tests I just couldn't get to work at all; I may leave
  #them here to document how things were supposed to work, but be wary of them
  #becoming stale.
  #If any fail, try running them alone and/or putting in a sleep around the failure
  #point.
  #Note there is also funniness with clicking on stuff (thus the uncommon variations
  #on that in this file).
  #Note also that some of the compound steps do things like run delayed job behind
  #the scenes, the price for making these tests a little more concise in this file.

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
    And I navigate to my accrual data for bag 'small-bag' at path 'dogs'
    Then I should see all of:
      | joe.txt | pete.txt | stuff |
    And I should see none of:
      | more.txt |

  @javascript
  Scenario: No conflict accrual, accepted
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-disjoint-bag' at path 'dogs'
    And I check all of:
      | joe.txt | stuff |
    And I click on 'Ingest'
    Then accrual assessment for the cfs directory with path 'dogs' has 1 files, 1 directories, 0 minor conflicts, and 0 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending'
    When I select accrual action 'Proceed'
    Then 'medusa-admin@example.com' should receive an email with subject 'Medusa accrual requested'
    And I relogin as an admin
    And I select accrual action 'Proceed'
    And I wait 1 second
    Then the cfs directory with path 'dogs' should have an accrual job with 0 files and 0 directories
    Then the file group titled 'Dogs' should have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'pete.txt'
    And the cfs directory with path 'dogs' should have an event with key 'deposit_completed' performed by 'manager@example.com'
    And accrual amazon backup for file group 'Dogs' and user 'manager@example.com' should happen
    When delayed jobs are run
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual completed'
    And the file group with title 'Dogs' should have an event with key 'amazon_backup_completed' performed by 'manager@example.com'
    And the archived accrual job with fields should exist:
      | state     |
      | completed |

  @javascript
  Scenario: No conflict accrual, aborted by repository admin
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-disjoint-bag' at path 'dogs'
    And I check all of:
      | joe.txt | stuff |
    And I click on 'Ingest'
    Then accrual assessment for the cfs directory with path 'dogs' has 1 files, 1 directories, 0 minor conflicts, and 0 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending'
    When I go to the dashboard
    And I select accrual action 'Abort'
    Then the cfs directory with path 'dogs' should not have an accrual job
    And the file group titled 'Dogs' should not have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt'
    And there should be 0 amazon backup delayed jobs
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual aborted'
    And the archived accrual job with fields should exist:
      | state   |
      | aborted |

  @javascript
  Scenario: No conflict accrual, aborted by preservation admin
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-disjoint-bag' at path 'dogs'
    And I check all of:
      | joe.txt | stuff |
    And I click on 'Ingest'
    Then accrual assessment for the cfs directory with path 'dogs' has 1 files, 1 directories, 0 minor conflicts, and 0 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending'
    When I go to the dashboard
    And I select accrual action 'Proceed'
    Then 'medusa-admin@example.com' should receive an email with subject 'Medusa accrual requested'
    And I relogin as an admin
    And I select accrual action 'Abort' with comment 'Abort message'
    Then the cfs directory with path 'dogs' should not have an accrual job
    And the file group titled 'Dogs' should not have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt'
    And there should be 0 amazon backup delayed jobs
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual aborted' containing all of:
      | Abort message |

  @javascript
  Scenario: Harmless conflict accrual, accepted
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-duplicate-overlap-bag' at path 'dogs'
    And I check all of:
      | joe.txt | intro.txt | stuff | pugs |
    And I click on 'Ingest'
    Then accrual assessment for the cfs directory with path 'dogs' has 2 files, 2 directories, 2 minor conflicts, and 0 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    And I select accrual action 'Proceed'
    Then 'medusa-admin@example.com' should receive an email with subject 'Medusa accrual requested' containing all of:
      | intro.txt | pugs/description.txt |
    And I relogin as an admin
    And I select accrual action 'Proceed'
    Then the cfs directory with path 'dogs' should have an accrual job with 0 files and 0 directories
    Then the file group titled 'Dogs' should have a cfs directory for the path 'stuff'
    And the file group titled 'Dogs' should have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'joe.txt'
    And accrual amazon backup for file group 'Dogs' and user 'manager@example.com' should happen
    When delayed jobs are run
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual completed'

  @javascript
  Scenario: Harmless conflict accrual, aborted by repository admin
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-duplicate-overlap-bag' at path 'dogs'
    And I check all of:
      | joe.txt | intro.txt | stuff | pugs |
    And I click on 'Ingest'
    Then accrual assessment for the cfs directory with path 'dogs' has 2 files, 2 directories, 2 minor conflicts, and 0 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    And I select accrual action 'Abort'
    Then the cfs directory with path 'dogs' should not have an accrual job
    And the file group titled 'Dogs' should not have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt'
    And there should be 0 amazon backup delayed jobs
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual aborted'

  @javascript
  Scenario: Harmless conflict accrual, aborted by preservation admin
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-duplicate-overlap-bag' at path 'dogs'
    And I check all of:
      | joe.txt | intro.txt | stuff | pugs |
    And I click on 'Ingest'
    Then accrual assessment for the cfs directory with path 'dogs' has 2 files, 2 directories, 2 minor conflicts, and 0 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    And I select accrual action 'Proceed'
    Then 'medusa-admin@example.com' should receive an email with subject 'Medusa accrual requested' containing all of:
      | intro.txt | pugs/description.txt |
    And I relogin as an admin
    And I select accrual action 'Abort' with comment 'Abort message'
    Then the cfs directory with path 'dogs' should not have an accrual job
    And the file group titled 'Dogs' should not have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt'
    And there should be 0 amazon backup delayed jobs
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual aborted' containing all of:
      | Abort message |

  @javascript
  Scenario: Changed conflict accrual, accepted
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-changed-overlap-bag' at path 'dogs'
    And I check all of:
      | joe.txt | intro.txt | stuff | pugs |
    And I click on 'Ingest'
    Then accrual assessment for the cfs directory with path 'dogs' has 2 files, 2 directories, 0 minor conflicts, and 2 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    When I select accrual action 'Proceed' with comment 'Request comment'
    Then 'medusa-admin@example.com' should receive an email with subject 'Medusa accrual requested' containing all of:
      | intro.txt | pugs/description.txt | Request comment |
    And I relogin as an admin
    And I select accrual action 'Proceed' with comment 'Approval comment'
    Then the cfs directory with path 'dogs' should have an accrual job with 0 files and 0 directories
    And the file group titled 'Dogs' should have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'pugs/description.txt' matching 'Changed Description text.'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt' matching 'Changed Intro text.'
    And accrual amazon backup for file group 'Dogs' and user 'manager@example.com' should happen
    When delayed jobs are run
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual completed'

  @javascript
  Scenario: Changed conflict accrual, aborted by repository manager
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-changed-overlap-bag' at path 'dogs'
    And I check all of:
      | joe.txt | intro.txt | stuff | pugs |
    And I click on 'Ingest'
    Then accrual assessment for the cfs directory with path 'dogs' has 2 files, 2 directories, 0 minor conflicts, and 2 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    When I select accrual action 'Abort'
    Then the cfs directory with path 'dogs' should not have an accrual job
    And the file group titled 'Dogs' should not have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt'
    And there should be 0 amazon backup delayed jobs
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual aborted'

  @javascript
  Scenario: Changed conflict accrual, aborted by preservation manager
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-changed-overlap-bag' at path 'dogs'
    And I check all of:
      | joe.txt | intro.txt | stuff | pugs |
    And I click on 'Ingest'
    Then accrual assessment for the cfs directory with path 'dogs' has 2 files, 2 directories, 0 minor conflicts, and 2 serious conflicts
    And 'manager@example.com' should receive an email with subject 'Medusa accrual pending' containing all of:
      | intro.txt | pugs/description.txt |
    When I select accrual action 'Proceed' with comment 'Request comment'
    Then 'medusa-admin@example.com' should receive an email with subject 'Medusa accrual requested' containing all of:
      | intro.txt | pugs/description.txt | Request comment |
    When I relogin as an admin
    When I select accrual action 'Abort' with comment 'Abort comment'
    Then the cfs directory with path 'dogs' should not have an accrual job
    And the file group titled 'Dogs' should not have a cfs file for the path 'stuff/more.txt'
    And the file group titled 'Dogs' should not have a cfs file for the path 'joe.txt'
    And the file group titled 'Dogs' should have a cfs file for the path 'intro.txt'
    And there should be 0 amazon backup delayed jobs
    Then 'manager@example.com' should receive an email with subject 'Medusa accrual aborted' containing all of:
      | Request comment | Abort comment |

  @javascript
  Scenario: Harmless conflict accrual, view report
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-duplicate-overlap-bag' at path 'dogs'
    And I check all of:
      | joe.txt | intro.txt | stuff | pugs |
    And I click on 'Ingest'
    And delayed jobs are run
    And I go to the dashboard
    And I click on 'Accruals'
    And I click on 'View Report'
    Then I should see all of:
      | intro.txt | 0 md5 conflicts |

  @javascript
  Scenario: Changed conflict accrual, view report
    When I am logged in as a manager
    And I navigate to my accrual data for bag 'accrual-changed-overlap-bag' at path 'dogs'
    And I check all of:
      | joe.txt | intro.txt | stuff | pugs |
    And I click on 'Ingest'
    And delayed jobs are run
    And I go to the dashboard
    And I click on 'Accruals'
    And I click on 'View Report'
    Then I should see all of:
      | intro.txt | 2 md5 conflicts |

  Scenario: When there is a job awaiting admin approval there is an extra icon for admins
    Given there is an accrual workflow job awaiting admin approval
    When I am logged in as an admin
    And I go to the dashboard
    Then there should be a notification icon
