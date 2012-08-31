Feature: Assessment description
  In order to track information about assessments
  As a librarian
  I want to edit assessment information

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has assessments with fields:
      | date       | preservation_risks                           | notes                                      |
      | 2012-01-09 | Old formats. http://preservation.example.com | Pictures of dogs. https://dogs.example.com |

  Scenario: View an assessment
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    Then I should see '2012-01-09'
    And I should see 'Old formats'
    And I should see 'Pictures of dogs'

  Scenario: Edit an assessment
    When I edit the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I fill in fields:
      | Notes | Images of canines |
    And I press 'Update Assessment'
    Then I should be on the view page for the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I should see 'Images of canines'
    And I should not see 'Pictures of dogs'

  Scenario: Navigate from the assessment view page to owning collection
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I click on 'Dogs'
    Then I should be on the view page for the collection titled 'Dogs'

  Scenario: Navigate from assessment view page to its edit page
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I click on 'Edit'
    Then I should be on the edit page for the assessment with date '2012-01-09' for the collection titled 'Dogs'

  Scenario: Delete assessment from view page
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I click on 'Delete'
    Then I should be on the view page for the collection titled 'Dogs'
    And The collection titled 'Dogs' should not have an assessment with date '2012-01-09'

  Scenario: Create a new assessment
    When I view the collection titled 'Dogs'
    And I click on 'Add Assessment'
    And I fill in fields:
      | Preservation risks | There are corrupt files too |
      | Notes              | I like dogs                 |
      | Date               | 2012-02-10                  |
    And I press 'Create Assessment'
    Then I should be on the view page for the assessment with date '2012-02-10' for the collection titled 'Dogs'
    And I should see 'I like dogs'
    And The collection titled 'Dogs' should have an assessment with date '2012-02-10'

  Scenario: Autofill user id for new assessment
    When I view the collection titled 'Dogs'
    And I click on 'Add Assessment'
    Then The field 'Author Net ID' should be filled in with 'admin'

  Scenario: Associate author with assessment
    When I edit the assessment with date '2012-01-09' for the collection titled 'Dogs'
    And I fill in fields:
      | Author Net ID | wingram2 |
    And I press 'Update Assessment'
    Then I should see 'wingram2'
    And There should be a person with net ID 'wingram2'

  Scenario: Auto link links from notes and preservation risks
    When I view the assessment with date '2012-01-09' for the collection titled 'Dogs'
    Then I should see a link to 'http://preservation.example.com'
    And I should see a link to 'https://dogs.example.com'
