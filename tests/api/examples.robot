*** Settings ***
Suite Setup       SuiteSetup
Test Setup        TestSetup
Resource    ../../resources/common/common_api.robot
Default Tags    glue

*** Test Cases ***
Examples
    I set Headers:    Content-Type=application/test  Accept=application/new-test
    When I send a GET request:    /api/users/2
    Then Response status code should be:    200
    And Response reason should be:    OK 

    