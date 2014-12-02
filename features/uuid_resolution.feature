Feature: UUID resolution
  In order to access content by uuid
  As any user
  I want the system to use a uuid to give me appropriate content

  Scenario: Unused uuid gives not found error
    When I visit the object with uuid '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    Then I should see 'No object with UUID 3da0fae0-e3fa-012f-ac10-005056b22849-8 was found.'
    And the http status should be '404'

  Scenario: Uuid for collection shows collection for admin
    Given I am logged in as an admin
    And the collection with title 'Dogs' exists
    And the uuid of the collection with title 'Dogs' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    When I visit the object with uuid '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    Then I should be on the view page for the collection with title 'Dogs'

  Scenario: Uuid for collection public shows collection for public
    Given I logout
    And the collection with title 'Dogs' exists
    And the uuid of the collection with title 'Dogs' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    And the collection with title 'Dogs' has public rights
    When I visit the object with uuid '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    Then I should be on the public view page for the collection with title 'Dogs'

  Scenario: Uuid for file group shows file group for admin
    Given I am logged in as an admin
    And the external file group with name 'Dogs' exists
    And the uuid of the file group with name 'Dogs' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    When I visit the object with uuid '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    Then I should be on the view page for the external file group with name 'Dogs'

  Scenario: Uuid for file group public shows file group for public
    Given I logout
    And the external file group with name 'Dogs' exists
    And the uuid of the file group with name 'Dogs' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    And the file group with name 'Dogs' has public rights
    When I visit the object with uuid '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    Then I should be on the public view page for the external file group with name 'Dogs'

  Scenario: Uuid for cfs directory shows cfs directory for admin
    Given I am logged in as an admin
    And the cfs directory with path 'dogs' exists
    And the uuid of the cfs directory with path 'dogs' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    When I visit the object with uuid '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    Then I should be on the view page for the cfs directory with path 'dogs'

  Scenario: Uuid for cfs directory public shows cfs directory for public
    Given I logout
    And the attached cfs directory with path 'dogs' exists
    And the uuid of the cfs directory with path 'dogs' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    And the cfs directory with path 'dogs' has public rights
    When I visit the object with uuid '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    Then I should be on the public view page for the cfs directory with path 'dogs'

  Scenario: Uuid for cfs file shows cfs file for admin
    Given I am logged in as an admin
    And the cfs file with name 'dogs' exists
    And the uuid of the cfs file with name 'dogs' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    When I visit the object with uuid '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    Then I should be on the view page for the cfs file with name 'dogs'

  Scenario: Uuid for cfs file public shows cfs file for public
    Given I logout
    And the attached cfs file with name 'dogs' exists
    And the uuid of the cfs file with name 'dogs' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    And the cfs file with name 'dogs' has public rights
    When I visit the object with uuid '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    Then I should be on the public view page for the cfs file with name 'dogs'
