Feature: Public views
  In order to use selected Medusa content
  As a public user
  I want to be able to view certain Medusa objects

  Background:
    Given I clear the cfs root directory
    And the physical cfs directory 'dogs' has a file 'intro.txt' with contents 'dog intro'
    And the physical cfs directory 'cats' has a file 'intro.txt' with contents 'cat intro'
    And the repository with title 'Animals' has child collections with fields:
      | title | description            | private_description     |
      | Dogs  | public dog description | private dog description |
      | Cats  | public dog description | private dog description |
    And the collection with title 'Dogs' has child file groups with fields:
      | name | type              | summary     | staged_file_location |
      | Dogs | BitLevelFileGroup | dog summary | /private/location    |
    And the collection with title 'Cats' has child file groups with fields:
      | name | type              | summary     | staged_file_location |
      | Cats | BitLevelFileGroup | cat summary | /private/location    |
    And the file group named 'Dogs' has cfs root 'dogs' and delayed jobs are run
    And the file group named 'Cats' has cfs root 'cats' and delayed jobs are run
    And the collection with title 'Dogs' has public rights
    And the file group with name 'Dogs' has public rights
    And the collection with title 'Cats' has private rights
    And the file group with name 'Cats' has private rights

  Scenario: View allowed collection metadata
    When I public view the collection with title 'Dogs'
    Then I should see all of:
      | Dogs | public dog description |
    And I should not see 'private dog description'

  Scenario: Attempt to view restricted collection metadata
    When I public view the collection with title 'Cats'
    Then I should be redirected to the unauthorized page

  Scenario: View allowed file group metadata
    When I public view the file group with name 'Dogs'
    Then I should see all of:
      | Dogs | dog summary |
    And I should not see '/private/location'

  Scenario: Attempt to view restricted file group metadata
    When I public view the file group with name 'Cats'
    Then I should be redirected to the unauthorized page

  Scenario: View allowed cfs directory metadata
    When I public view the cfs directory for the file group named 'Dogs' for the path '.'
    Then I should see all of:
      | intro.txt |

  Scenario: Attempt to view restricted cfs directory metadata
    When I public view the cfs directory for the file group named 'Cats' for the path '.'
    Then I should be redirected to the unauthorized page

  Scenario: View allowed cfs file metadata
    When I public view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    Then I should see all of:
      | intro.txt | 9 Bytes | f346bd77c403097b0656ecd011e8c118 | text/plain |

  Scenario: Attempt to view restricted cfs file metadata
    When I public view the cfs file for the file group named 'Cats' for the path 'intro.txt'
    Then I should be redirected to the unauthorized page

  Scenario: Download allowed file
    When I public view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    And I click on 'Download'
    Then I should have downloaded a file 'intro.txt' with contents 'dog intro'

  Scenario: View allowed file
    When I public view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    And I click on 'View'
    Then I should have viewed a file 'intro.txt' with contents 'dog intro'

  #For convenience here we do this and the next a bit artificially
  Scenario: Attempt to download restricted file
    When I public view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    And the file group with name 'Dogs' has private rights
    And I click on 'Download'
    Then I should be redirected to the unauthorized page

  Scenario: Attempt to view restricted file
    When I public view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    And the file group with name 'Dogs' has private rights
    And I click on 'View'
    Then I should be redirected to the unauthorized page

  Scenario: Attempt to view internal collection info is redirected to public if available
    When PENDING
    When I view the collection with title 'Dogs'
    Then I should be on the public view page for the collection with title 'Dogs'

  Scenario: Attempt to view internal file group info is redirected to public if available
    When PENDING
    When I view the file group with name 'Dogs'
    Then I should be on the public view page for the file group with name 'Dogs'

  Scenario: Attempt to view internal cfs directory info is redirected to public if available
    When PENDING
    When I view the cfs directory for the file group named 'Dogs' for the path '.'
    Then I should be public viewing the cfs directory for the file group named 'Dogs' for the path '.'

  Scenario: Attempt to view internal cfs file info is redirected to public if available
    When PENDING
    When I view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    Then I should be public viewing the cfs file for the file group named 'Dogs' for the path 'intro.txt'

  Scenario: Navigation between these
    Given PENDING

  Scenario: Links from private to public versions (for sharing)
    Given PENDING