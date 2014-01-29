Feature: MODS for collection
  In order to manage preservation
  As a librarian
  I want to be able to view MODS metadata for a collection

  Background:
    Given the repository titled 'Animals' has collections with fields:
      | title | description        | access_url              | start_date | end_date   | uuid                                   |
      | Dogs  | Collection of dogs | http://dogs.example.com | 2012-01-20 | 2012-09-18 | 3da0fae0-e3fa-012f-ac10-005056b22849-8 |
    And the collection titled 'Dogs' has resource types named:
      | text | cartographic |

  Scenario: Link from collection show view to MODS
    Given I am logged in as 'admin'
    When I view the collection titled 'Dogs'
    And I click on 'Mods'
    Then I should see a valid MODS document

  Scenario: The MODS document contains all required fields
    Given I am logged in as 'admin'
    When I view MODS for the collection titled 'Dogs'
    Then I should see MODS fields by css:
      | titleInfo title                                           | Dogs                                                |
      | typeOfResource[collection="yes"]                          | text                                                |
      | typeOfResource[collection="yes"]                          | cartographic                                        |
      | location url[usage="primary"][access="object in context"] | http://dogs.example.com                             |
      | abstract                                                  | Collection of dogs                                  |
      | originInfo publisher                                      | Animals                                             |
      | originInfo dateOther[point="start"]                       | 2012-01-20                                          |
      | originInfo dateOther[point="end"]                         | 2012-09-18                                          |
      | identifier[type="uuid"]                                   | 3da0fae0-e3fa-012f-ac10-005056b22849-8              |
      | identifier[type="handle"]                                 | 10111/MEDUSA:3da0fae0-e3fa-012f-ac10-005056b22849-8 |

  Scenario: The MODS document is viewable by basic auth user
    Given I provide basic authentication
    When I view MODS for the collection titled 'Dogs'
    Then I should see a valid MODS document