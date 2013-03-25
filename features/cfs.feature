Feature: CFS integration
  In order to temporarily preserve and work with files before ingest
  As a librarian
  I want to be able to work with a CFS file share exposed as a local directory

  Background:
    Given I am logged in as an admin
    And there is a cfs directory 'dogs/pugs'
    And the cfs directory 'dogs' has files:
      | intro.txt |
    And the cfs directory 'dogs/pugs' has files:
      | picture.jpg | description.txt |

  Scenario: View CFS directory
    When I view the cfs path 'dogs'
    Then I should see all of:
      | intro.txt | pugs |

  Scenario: Navigate CFS directory down
    When I view the cfs path 'dogs'
    And I click on 'pugs'
    Then I should be viewing the cfs directory 'dogs/pugs'

  Scenario: Navigate CFS directory up
    When I view the cfs path 'dogs/pugs'
    And I click on 'dogs'
    Then I should be viewing the cfs directory 'dogs'

  Scenario: View a file
    When I view the cfs path 'dogs'
    And I click on 'intro.txt'
    Then I should be viewing the cfs file 'dogs/intro.txt'

  Scenario: Try to view non-existent directory
    When I view the cfs path 'dogs/chihuahuas'
    Then the response code should be 404


