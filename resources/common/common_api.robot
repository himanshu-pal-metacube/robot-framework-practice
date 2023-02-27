*** Settings ***
Library    RequestsLibrary
Library    String
Library    Dialogs
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    DateTime
Library    JSONLibrary
Library    DatabaseLibrary
Library    ../../resources/libraries/common.py

*** Variables ***
# *** SUITE VARIABLES ***
${api_timeout}                 60
${default_allow_redirects}     true
${default_auth}                ${NONE}

*** Keywords ***
SuiteSetup
    [Documentation]    Basic steps before each suite. Should be sed with the ``Suite Setup`` tag.
    ...
    ...    *Example:*
    ...
    ...    ``Suite Setup       SuiteSetup``
    Remove Files    ${OUTPUTDIR}/selenium-screenshot-*.png
    Remove Files    resources/libraries/__pycache__/*
    Load Variables    ${env}
    ${random}=    Generate Random String    5    [NUMBERS]
    Set Global Variable    ${random}
    ${today}=    Get Current Date    result_format=%Y-%m-%d
    Set Global Variable    ${today}
    [Teardown]
    [Return]    ${random}

TestSetup
    [Documentation]   This setup should be called in Settings of every test suite. It defines which url variable will be used in the test suite.
    ...
    ...    At the moment it is used to define if the test is for GLUE (``glue`` tag) or BAPI (``bapi`` tag) by checking for the default or test tag.
    ...    If the tag is there it replaces the domein URL with bapi url.
    ...
    ...    To set a tag to a test case use ``[Tags]`` under the test name.
    ...    To set default tags for the whole test suite (.robotframework file), use ``Default Tags`` keyword in the suite Settings.
    ...
    ...    *Notes*:
    ...
    ...    1. If a test suite has no Test Setup and/or tests in the suite have no bapi/glue tags, GLUE URL will be used by default as the current URL.
    ...
    ...    2. Do not set both tags to a suite, each suite/robot file should have tests only for GLUE or only for BAPI.
    ...
    ...    3. You can set other tags for tests and suites with no restrictions, they will be ignored in suite setup.
    ...
    ...    *Example:*
    ...
    ...    ``*** Settings ***``
    ...
    ...    ``Test Setup    TestSetup``
    ...
    ...    ``Default Tags    bapi``
    FOR  ${tag}  IN  @{Test Tags}
        Log   ${tag}
        IF    '${tag}'=='bapi'    Set Suite Variable    ${current_url}    ${bapi_url}
        IF    '${tag}'=='glue'    Set Suite Variable    ${current_url}    ${glue_url}
    END
    Log    ${current_url}

Load Variables
    [Documentation]    Keyword is used to load variable values from the environment file passed during execution. This Keyword is used during suite setup.
    ...    It accepts the name of the environment as specified at the beginning of an environment file e.g. ``"environment": "api_demo"``.
    ...
    ...    These variables are loaded and usable throughtout all tests of the test suite, if this keyword is called during suite setup.
    ...
    ...    *Example:*
    ...
    ...    ``Load Variables    ${env}``
    ...
    ...    ``Load Variables    api_demo``
    [Arguments]    ${env}
    &{vars}=   Define Environment Variables From Json File    ${env}
    FOR    ${key}    ${value}    IN    &{vars}
        Log    Key is '${key}' and value is '${value}'.
        Set Global Variable    ${${key}}    ${value}
    END

I set Headers:
    [Documentation]    Keyword sets any number of headers for the further endpoint calls.
    ...    Headers can have any name and any value, they are set as test variable - which means they can be used throughtout one test if set once.
    ...    This keyword can be used to add access token to the next endpoint calls or to set header for the guest customer, etc.
    ...
    ...    It accepts a list of pairs haader-name=header-value as an argument. The list items should be separated by 4 spaces.
    ...
    ...    *Example:*
    ...
    ...    ``I set Headers:    Content-Type=${default_header_content_type}    Authorization=${token}``

    [Arguments]    &{headers}
    Set Test Variable    &{headers}
    [Return]    &{headers}

I send a GET request:
    [Documentation]    This keyword is used to make GET requests. It accepts the endpoint *without the domain*.
    ...    Variables can and should be used in the endpoint url.
    ...
    ...    If the endpoint needs to have any headers (e.g. token for authorisation), ``I set Headers`` keyword should be called before this keyword to set the headers beforehand.
    ...    If this keyword was already called within this test case (e.g. before POST request), there is no need to call it again.
    ...
    ...    After this keyword is called, response body, response status and headers are recorded into the test variables which have the scope of the current test and can then be used by other keywords to get and compare data.
    ...
    ...    *Example:*
    ...
    ...    ``I send a GET request:    /api/users/${user_id}``
    [Arguments]   ${path}    ${timeout}=${api_timeout}    ${allow_redirects}=${default_allow_redirects}    ${auth}=${default_auth}    ${expected_status}=ANY
    ${hasValue}    Run Keyword and return status     Should not be empty    ${headers}
    ${response}=    IF    ${hasValue}   run keyword    GET    ${current_url}${path}    headers=${headers}    timeout=${timeout}    allow_redirects=${allow_redirects}    auth=${auth}    expected_status=${expected_status}
    ...    ELSE    GET    ${current_url}${path}    timeout=${timeout}    allow_redirects=${allow_redirects}    auth=${auth}    expected_status=${expected_status}
    ${response_body}=    IF    ${response.status_code} != 204    Set Variable    ${response.json()}
    ${response_headers}=    Set Variable    ${response.headers}
    Set Test Variable    ${response_headers}    ${response_headers}
    Set Test Variable    ${response_body}    ${response_body}
    Set Test Variable    ${response}    ${response}
    Set Test Variable    ${expected_self_link}    ${current_url}${path}
    [Return]    ${response_body}

I send a POST request:
    [Documentation]    This keyword is used to make POST requests. It accepts the endpoint *without the domain* and the body in JOSN.
    ...    Variables can and should be used in the endpoint url and in the body JSON.
    ...
    ...    If the endpoint needs to have any headers (e.g. token for authorisation), ``I set Headers`` keyword should be called before this keyword to set the headers beforehand.
    ...
    ...    After this keyword is called, response body, response status and headers are recorded into the test variables which have the scope of the current test and can then be used by other keywords to get and compare data.
    ...
    ...    *Example:*
    ...
    ...    ``I send a POST request:    /api/users    {"name": "${user_name}","job": "${user_occupation}"}``
    [Arguments]   ${path}    ${json}    ${timeout}=${api_timeout}    ${allow_redirects}=${default_allow_redirects}    ${auth}=${default_auth}    ${expected_status}=ANY
    ${data}=    Evaluate    ${json}
    ${hasValue}    Run Keyword and return status     Should not be empty    ${headers}
    ${response}=    IF    ${hasValue}   run keyword    POST    ${current_url}${path}    json=${data}    headers=${headers}    timeout=${timeout}    allow_redirects=${allow_redirects}    auth=${auth}    expected_status=${expected_status}
    ...    ELSE    POST    ${current_url}${path}    json=${data}    timeout=${timeout}    allow_redirects=${allow_redirects}    auth=${auth}    expected_status=ANY
    ${response_body}=    IF    ${response.status_code} != 204    Set Variable    ${response.json()}
    ${response_headers}=    Set Variable    ${response.headers}
    Set Test Variable    ${response_headers}    ${response_headers}
    Set Test Variable    ${response_body}    ${response_body}
    Set Test Variable    ${response}    ${response}
    Set Test Variable    ${expected_self_link}    ${current_url}${path}
    [Return]    ${response_body}

Response reason should be:
    [Documentation]    This keyword checks that response reason saved  in ``${response}`` test variable matches the reason passed as an argument.
    ...
    ...    *Example:*
    ...
    ...    ``Response reason should be:    Created``
    [Arguments]    ${reason}
    Should Be Equal As Strings    ${reason}    ${response.reason}

Response status code should be:
    [Documentation]    This keyword checks that response status code saved  in ``${response}`` test variable matches the status code passed as an argument.
    ...
    ...    *Example:*
    ...
    ...    ``Response status code should be:    201``
    [Arguments]    ${status_code}
    Should Be Equal As Strings    ${response.status_code}    ${status_code}

Response body should contain:
    [Documentation]    This keyword checks that the response saved  in ``${response_body}`` test variable contsains the string passed as an argument.
    ...
    ...    *Example:*
    ...
    ...    ``Response body should contain:    "localizedName": "Weight"``
    [Arguments]    ${value}
    ${response_body}=    Convert To String    ${response_body}
    ${response_body}=    Replace String    ${response_body}    '    "
    Should Contain    ${response_body}    ${value}

Response body parameter should be:
    [Documentation]    This keyword checks that the response saved  in ``${response_body}`` test variable contsains the speficied parameter ``${json_path}`` with he specified value ``${expected_value}``.
    ...
    ...    *Example:*
    ...
    ...    ``Response body parameter should be:    [data][0][name]    ${user_name}``
    [Arguments]    ${json_path}    ${expected_value}
    ${data}=    Get Value From Json    ${response_body}    ${json_path}
    ${data}=    Convert To String    ${data}
    ${data}=    Replace String    ${data}    '   ${EMPTY}
    ${data}=    Replace String    ${data}    [   ${EMPTY}
    ${data}=    Replace String    ${data}    ]   ${EMPTY}
    Log    ${data}
    Should Be Equal    ${data}    ${expected_value}