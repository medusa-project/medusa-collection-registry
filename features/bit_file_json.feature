Feature: JSON data about bit file
  In order to expose bit file data to other applications
  As the system
  I want to be able to export JSON describing a bit file

  Background:
    Given I have a directory named 'animal-files'
    And the directory named 'animal-files' has bit files with fields:
      | name    | size | content_type | dx_ingested | md5sum                   | dx_name                                |
      | dog.jpg | 9208 | image/jpeg   | true     | G7jiO82hrgstPNSD2t00Hw== | 0cdf6b50-2d1e-0130-bc56-000c2967d45f-9 |

    Scenario: Get JSON for a bit file
      When I request JSON for the bit file named 'dog.jpg'
      Then the JSON should have "id"
      And the JSON should have "directory_id"
      And the JSON at "size" should be 9208
      And the JSON at "content_type" should be "image/jpeg"
      And the JSON at "ingested" should be true
      And the JSON at "md5sum" should be "G7jiO82hrgstPNSD2t00Hw=="
      And the JSON at "url" should be "http://libstor.grainger.illinois.edu/test/0cdf6b50-2d1e-0130-bc56-000c2967d45f-9"
