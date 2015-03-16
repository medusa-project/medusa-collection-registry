Feature: Fixity Checking
  In order to ensure continuing integrity of files
  As a repository administrator
  I want to be able to run fixity checks on my file

  Background:
    Given I am logged in as an admin
    And I clear the cfs root directory
    And the physical cfs directory 'dogs/toy-dogs' has a file 'picture.jpg' with contents 'picture stuff'
    And the physical cfs directory 'dogs/toy-dogs/yorkies' has a file 'something.txt' with contents 'some text'
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | title   | type              |
      | Toys    | BitLevelFileGroup |
      | Workers | BitLevelFileGroup |
    And the file group titled 'Toys' has cfs root 'dogs/toy-dogs' and delayed jobs are run

  Scenario: Fixity check against unchanged files from file group level
    When I view the file group with title 'Toys'
    And I click on 'Fixity check'
    Then the file group with title 'Toys' should have an event with key 'fixity_check_scheduled' performed by 'admin@example.com'
    When delayed jobs are run
    Then the cfs file with name 'picture.jpg' should have events with fields:
      | key           | note | cascadable |
      | fixity_result | OK   | false      |
    And the cfs file with name 'something.txt' should have events with fields:
      | key           | note | cascadable |
      | fixity_result | OK   | false      |
    And the file group with title 'Toys' should have an event with key 'fixity_check_completed' performed by 'admin@example.com'

  Scenario: Fixity check with changed file from file group level
    When the physical cfs directory 'dogs/toy-dogs/yorkies' has a file 'something.txt' with contents 'some changed text'
    And I view the file group with title 'Toys'
    And I click on 'Fixity check'
    Then the file group with title 'Toys' should have an event with key 'fixity_check_scheduled' performed by 'admin@example.com'
    When delayed jobs are run
    Then the cfs file with name 'picture.jpg' should have events with fields:
      | key           | note | cascadable |
      | fixity_result | OK   | false      |
    Then the cfs file with name 'something.txt' should have events with fields:
      | key           | note   | cascadable |
      | fixity_result | FAILED | true       |
    And the file group with title 'Toys' should have cascadable events with fields:
      | key           | note   |
      | fixity_result | FAILED |
    And the file group titled 'Toys' has a cfs file for the path 'yorkies/something.txt' with red flags with fields:
      | status  | priority | message                                                                                               |
      | flagged | medium   | Md5 Sum changed. Recorded: 552e21cd4cd9918678e3c1a0df491bc3 Current: c9dbfcbc15a9126cadeeb7af719267a5 |
    And the file group with title 'Toys' should have an event with key 'fixity_check_completed' performed by 'admin@example.com'


  Scenario: File group without cfs root doesn't have a fixity check link
    When I view the file group with title 'Workers'
    Then I should not see 'Run fixity check'

  Scenario: Fixity check against unchanged files from directory level
    When I view the cfs directory for the file group titled 'Toys' for the path 'yorkies'
    And I click on 'Fixity check'
    Then the cfs directory with path 'yorkies' should have an event with key 'fixity_check_scheduled' performed by 'admin@example.com'
    When delayed jobs are run
    And the cfs file with name 'something.txt' should have events with fields:
      | key           | note | cascadable |
      | fixity_result | OK   | false      |
    And the cfs file with name 'picture.jpg' should have 0 events
    And the cfs directory with path 'yorkies' should have an event with key 'fixity_check_completed' performed by 'admin@example.com'
    When I view the cfs directory for the file group titled 'Toys' for the path 'yorkies'
    And I click on 'Events'
    Then I should see all of:
      | Fixity check scheduled | Fixity check completed |
    And I should see none of:
      | Fixity result | OK |
    When I view the file group with title 'Toys'
    And I click on 'Events'
    Then I should see all of:
      | Fixity check scheduled | Fixity check completed |
    And I should see none of:
      | Fixity result | OK |

  Scenario: Fixity check with changed file from directory level
    When the physical cfs directory 'dogs/toy-dogs/yorkies' has a file 'something.txt' with contents 'some changed text'
    And I view the cfs directory for the file group titled 'Toys' for the path 'yorkies'
    And I click on 'Fixity check'
    Then the cfs directory with path 'yorkies' should have an event with key 'fixity_check_scheduled' performed by 'admin@example.com'
    When delayed jobs are run
    And the cfs file with name 'something.txt' should have events with fields:
      | key           | note   | cascadable |
      | fixity_result | FAILED | true       |
    And the cfs file with name 'picture.jpg' should have 0 events
    And the cfs directory with path 'yorkies' should have an event with key 'fixity_check_completed' performed by 'admin@example.com'
    When I view the cfs directory for the file group titled 'Toys' for the path 'yorkies'
    And I click on 'Events'
    Then I should see all of:
      | Fixity check scheduled | Fixity check completed | Fixity result | FAILED |
    When I view the file group with title 'Toys'
    And I click on 'Events'
    Then I should see all of:
      | Fixity check scheduled | Fixity check completed | Fixity result | FAILED |

  Scenario: Fixity check of unchanged file from file level
    When I view the cfs file for the file group titled 'Toys' for the path 'yorkies/something.txt'
    And I click on 'Fixity check'
    And the cfs file with name 'something.txt' should have events with fields:
      | key              | note | cascadable | actor_email       |
      | fixity_check_run |      | false      | admin@example.com |
      | fixity_result    | OK   | false      | admin@example.com |
    When I view the cfs file for the file group titled 'Toys' for the path 'yorkies/something.txt'
    And I click on 'Events'
    Then I should see all of:
      | Fixity check run | Fixity result | OK |
    When I view the cfs directory for the file group titled 'Toys' for the path 'yorkies'
    And I click on 'Events'
    Then I should see none of:
      | Fixity check run | Fixity result | OK |

  Scenario: Fixity check of changed file from file level
    When the physical cfs directory 'dogs/toy-dogs/yorkies' has a file 'something.txt' with contents 'some changed text'
    And I view the cfs file for the file group titled 'Toys' for the path 'yorkies/something.txt'
    And I click on 'Fixity check'
    And the cfs file with name 'something.txt' should have events with fields:
      | key              | note   | cascadable | actor_email       |
      | fixity_check_run |        | false      | admin@example.com |
      | fixity_result    | FAILED | true       | admin@example.com |
    When I view the cfs file for the file group titled 'Toys' for the path 'yorkies/something.txt'
    And I click on 'Events'
    Then I should see all of:
      | Fixity check run | Fixity result | FAILED |
    When I view the cfs directory for the file group titled 'Toys' for the path 'yorkies'
    And I click on 'Events'
    Then I should see none of:
      | Fixity check run |
    And I should see all of:
      | Fixity result | FAILED |

  Scenario: Visitors and public cannot order fixity checks. Public user cannot view events for cfs directory and cfs file.
    Then deny object permission on the file group with title 'Toys' to users for action with redirection:
      | public user | fixity_check(post) | authentication |
      | visitor     | fixity_check(post) | unauthorized   |
    Then deny object permission on the cfs directory with path 'yorkies' to users for action with redirection:
      | public user | fixity_check(post), events | authentication |
      | visitor     | fixity_check(post)         | unauthorized   |
    Then deny object permission on the cfs file with name 'something.txt' to users for action with redirection:
      | public user | fixity_check(post), events | authentication |
      | visitor     | fixity_check(post)         | unauthorized   |

  Scenario: Failed fixity events are visible all the way up to the repository level
    Given the cfs file with name 'something.txt' has events with fields:
      | key           | note   | actor_email       | cascadable |
      | fixity_result | FAILED | admin@example.com | true       |
      | fixity_result | OK     | admin@example.com | false      |
    When I view the cfs directory for the file group titled 'Toys' for the path '.'
    And I click on 'Events'
    Then I should see all of:
      | Fixity result | FAILED | something.txt |
    And I should not see 'OK'
    When I view the file group with title 'Toys'
    And I click on 'Events'
    Then I should see all of:
      | Fixity result | FAILED | something.txt |
    And I should not see 'OK'
    When I view the collection with title 'Dogs'
    And I click on 'Events'
    Then I should see all of:
      | Fixity result | FAILED | something.txt |
    And I should not see 'OK'
    When I view the repository with title 'Animals'
    And I click on 'Events'
    Then I should see all of:
      | Fixity result | FAILED | something.txt |
    And I should not see 'OK'
