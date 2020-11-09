@api
Feature: get file info using PUT

  Background:
    Given user "Alice" has been created with default attributes and without skeleton files
    And user "Alice" has uploaded file with content "some data" to "/textfile0.txt"
    And user "Alice" has uploaded file with content "some data" to "/textfile1.txt"
    And user "Alice" has created folder "/PARENT"
    And user "Alice" has created folder "/FOLDER"
    And user "Alice" has uploaded file with content "some data" to "/PARENT/parent.txt"
    And user "Brian" has been created with default attributes and without skeleton files

  @smokeTest
  @skipOnBruteForceProtection @issue-brute_force_protection-112
  Scenario: send PUT requests to webDav endpoints as normal user with wrong password
    When user "Alice" requests these endpoints with "PUT" including body "doesnotmatter" using password "invalid" about user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @smokeTest
  @skipOnBruteForceProtection @issue-brute_force_protection-112
  Scenario: send PUT requests to webDav endpoints as normal user with no password
    When user "Alice" requests these endpoints with "PUT" including body "doesnotmatter" using password "" about user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @issue-ocis-reva-9 @issue-ocis-reva-197
  Scenario: send PUT requests to another user's webDav endpoints as normal user
    When user "Brian" requests these endpoints with "PUT" including body "doesnotmatter" about user "Alice"
      | endpoint                                       |
      | /remote.php/dav/files/%username%/textfile1.txt |
      | /remote.php/dav/files/%username%/PARENTS       |
    Then the HTTP status code of responses on all endpoints should be "403"
    When user "Brian" requests these endpoints with "PUT" including body "doesnotmatter" about user "Alice"
      | endpoint                                            |
      | /remote.php/dav/files/%username%/PARENTS/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "409"

  Scenario: send PUT requests to webDav endpoints using invalid username but correct password
    When user "usero" requests these endpoints with "PUT" including body "doesnotmatter" using the password of user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  Scenario: send PUT requests to webDav endpoints using valid password and username of different user
    When user "Brian" requests these endpoints with "PUT" including body "doesnotmatter" using the password of user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @smokeTest
  @skipOnBruteForceProtection @issue-brute_force_protection-112
  Scenario: send PUT requests to webDav endpoints without any authentication
    When a user requests these endpoints with "PUT" with body "doesnotmatter" and no authentication about user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @notToImplementOnOCIS @issue-ocis-reva-37
  Scenario: send PUT requests to webDav endpoints using token authentication should not work
    Given token auth has been enforced
    And a new browser session for "Alice" has been started
    And the user has generated a new app password named "my-client"
    When the user requests these endpoints with "PUT" using the generated app password about user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile0.txt     |
      | /remote.php/webdav/PARENT                          |
      | /remote.php/dav/files/%username%/PARENT            |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "401"

  @notToImplementOnOCIS @issue-ocis-reva-37
  Scenario: send PUT requests to webDav endpoints using app password token as password
    Given token auth has been enforced
    And a new browser session for "Alice" has been started
    And the user has generated a new app password named "my-client"
    When the user "Alice" requests these endpoints with "PUT" with body "doesnotmatter" using basic auth and generated app password about user "Alice"
      | endpoint                                           |
      | /remote.php/webdav/textfile0.txt                   |
      | /remote.php/dav/files/%username%/textfile1.txt     |
      | /remote.php/dav/files/%username%/PARENT/parent.txt |
    Then the HTTP status code of responses on all endpoints should be "204"
    When the user "Alice" requests these endpoints with "PUT" with body "doesnotmatter" using basic auth and generated app password about user "Alice"
      | endpoint                                 |
      # this folder is created, so gives 201 - CREATED
      | /remote.php/webdav/PARENS                |
      | /remote.php/dav/files/%username%/FOLDERS |
    Then the HTTP status code of responses on all endpoints should be "201"
    When the user "Alice" requests these endpoints with "PUT" with body "doesnotmatter" using basic auth and generated app password about user "Alice"
      | endpoint                                |
      # this folder already exists so gives 409 - CONFLICT
      | /remote.php/dav/files/%username%/FOLDER |
    Then the HTTP status code of responses on all endpoints should be "409"
