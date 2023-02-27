*** Settings ***
Library    Browser
Library    String
Library    Dialogs
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    DateTime
Library    ../../resources/libraries/common.py
Library    Telnet
Library    RequestsLibrary
Library    DatabaseLibrary


*** Variables ***
# *** SUITE VARIABLES ***
${env}                 ui_demo
${headless}            true
${browser}             chromium
${browser_timeout}     60 seconds
${email_domain}        @test.com
${default_password}    change123
${admin_email}         admin@test.com
${device}
# *** DB VARIABLES ***
${default_db_host}         127.0.0.1
${default_db_name}         test-db
${default_db_password}     secret
${default_db_port}         3306
${default_db_user}         test_db
${default_db_engine}       pymysql
${db_engine}
# ${default_db_engine}       psycopg2

# ${device}              Desktop Chrome
# ${fake_email}          test.1+${random}@gmail.com

*** Keywords ***
Load Variables
    [Arguments]    ${env}
    &{vars}=   Define Environment Variables From Json File    ${env}
    FOR    ${key}    ${value}    IN    &{vars}
        Log    Key is '${key}' and value is '${value}'.
        ${var_value}=   Get Variable Value  ${${key}}   ${value}
        Set Global Variable    ${${key}}    ${var_value}
    END

Set Up Keyword Arguments
    [Arguments]    @{args}
    &{arguments}=    Fill Variables From Text String    @{args}
    FOR    ${key}    ${value}    IN    &{arguments}
        Log    Key is '${key}' and value is '${value}'.
        ${var_value}=   Set Variable    ${value}
        Set Test Variable    ${${key}}    ${var_value}
    END
    [Return]    &{arguments}

SuiteSetup
    [documentation]  Basic steps before each suite
    Remove Files    ${OUTPUTDIR}/selenium-screenshot-*.png
    Remove Files    resources/libraries/__pycache__/*
    Load Variables    ${env}
    New Browser    ${browser}    headless=${headless}    args=['--ignore-certificate-errors']
    Set Browser Timeout    ${browser_timeout}
    Create default Main Context
    New Page    ${host}
    ${random}=    Generate Random String    5    [NUMBERS]
    Set Global Variable    ${random}
    ${today}=    Get Current Date    result_format=%Y-%m-%d
    Set Global Variable    ${today}
    ${test_customer_email}=     set variable    test.1+${random}@gmail.com
    Set Global Variable  ${test_customer_email}
    [Teardown]
    [Return]    ${random}

SuiteTeardown
    Close Browser    ALL

TestSetup
    Delete All Cookies
    Go To    ${host}

TestTeardown
    # Run Keyword If Test Failed    Pause Execution
    Delete All Cookies

Create default Main Context
    Log    ${device}
    IF  '${device}' == '${EMPTY}'
        ${main_context}=    New Context    viewport={'width': 1440, 'height': 1080}
    ELSE
        ${device}=    Get Device    ${device}
        ${main_context}=    New Context    &{device}
    END
    Set Suite Variable    ${main_context}

Select Random Option From List
    [Arguments]    ${dropDownLocator}    ${dropDownOptionsLocator}
    ${getOptionsCount}=    Get Element Count    ${dropDownOptionsLocator}
    ${index}=    Evaluate    random.randint(0, ${getOptionsCount}-1)    random
    ${index}=    Convert To String    ${index}
    Select From List By Index    ${dropDownLocator}    ${index}

# Helper keywords for migration from Selenium Library to Browser Library
Wait Until Element Is Visible
    [Arguments]    ${locator}    ${message}=${EMPTY}    ${timeout}=${browser_timeout}
    Wait For Elements State    ${locator}    visible    ${timeout}    ${message}

Wait Until Page Contains Element
    [Arguments]    ${locator}    ${message}=${EMPTY}    ${timeout}=${browser_timeout}
    Wait For Elements State    ${locator}    attached    ${timeout}    ${message}

Wait Until Page Does Not Contain Element
    [Arguments]    ${locator}    ${message}=${EMPTY}    ${timeout}=${browser_timeout}
    Wait For Elements State    ${locator}    detached    ${timeout}    ${message}

Wait Until Element Is Enabled
    [Arguments]    ${locator}    ${message}=${EMPTY}    ${timeout}=${browser_timeout}
    Wait For Elements State    ${locator}    enabled    ${timeout}    ${message}

Element Should Be Visible
    [Arguments]    ${locator}    ${message}=${EMPTY}    ${timeout}=0:00:05
    Wait For Elements State    ${locator}    visible    ${timeout}    ${message}

Page Should Contain Element
    [Arguments]    ${locator}    ${message}=${EMPTY}    ${timeout}=0:00:05
    Wait For Elements State    ${locator}    attached    ${timeout}    ${message}

Get Location
    ${current_location}=    Get URL
    ${location}=    Set Variable    ${current_location}
    Set Test Variable    ${location}    ${location}
    [Return]    ${location}

Save current URL
    ${current_url}=    Get URL
    ${url}=    Set Variable    ${current_url}
    Set Test Variable    ${url}    ${url}
    [Return]    ${url}

Wait Until Element Is Not Visible
    [Arguments]    ${locator}    ${message}=${EMPTY}    ${timeout}=${browser_timeout}
    Wait For Elements State    ${locator}    hidden    ${timeout}    ${message}

Input Text
    [Arguments]    ${locator}    ${text}
    Type Text    ${locator}    ${text}    0ms

Table Should Contain
    [Arguments]    ${locator}    ${expected}    ${message}=${EMPTY}    ${ignore_case}=${EMPTY}
    Get Text    ${locator}    contains    ${expected}    ${message}

Table Should Not Contain
    [Arguments]    ${locator}    ${expected}    ${message}=${EMPTY}    ${ignore_case}=${EMPTY}
    Get Text    ${locator}    not contains    ${expected}    ${message}

Element Should Contain
    [Arguments]    ${locator}    ${expected}    ${message}=${EMPTY}    ${ignore_case}=${EMPTY}
    Get Text    ${locator}    contains    ${expected}    ${message}

Element Text Should Be
    [Arguments]    ${locator}    ${expected}    ${message}=${EMPTY}    ${ignore_case}=${EMPTY}
    Get Text    ${locator}    equal    ${expected}    ${message}

Page Should Not Contain Element
    [Arguments]    ${locator}    ${message}=${EMPTY}    ${timeout}=0:00:05
    Wait For Elements State    ${locator}    detached    ${timeout}    ${message}

Element Should Not Contain
    [Arguments]    ${locator}    ${text}
    Get Text    ${locator}    validate    "${text}" not in value

Checkbox Should Be Selected
    [Arguments]    ${locator}
    Get Checkbox State    ${locator}    ==    checked

Checkbox Should Not Be Selected
    [Arguments]    ${locator}
    Get Checkbox State    ${locator}    ==    unchecked

Mouse Over
    [Arguments]    ${locator}
    Hover    ${locator}

Element Should Not Be Visible
    [Arguments]    ${locator}    ${message}=${EMPTY}    ${timeout}=0:00:05
    Wait For Elements State    ${locator}    hidden    ${timeout}    ${message}

Select From List By Label
    [Arguments]    ${locator}    ${value}
    Select Options By    ${locator}    label    ${value}

Select From List By Value
    [Arguments]    ${locator}    ${value}
    Select Options By    ${locator}    value    ${value}

Select From List By Index
    [Arguments]    ${locator}    ${value}
    Select Options By    ${locator}    index    ${value}

Select From List By Text
    [Arguments]    ${locator}    ${value}
    Select Options By    ${locator}    text    ${value}

Try reloading page until element is/not appear:
    [Documentation]    will reload the page until an element is shown or disappears. The second argument is the expected condition (true[shown]/false[disappeared]) for the element.
    [Arguments]    ${element}    ${shouldBeDisplayed}    ${tries}=20    ${timeout}=1s
    FOR    ${index}    IN RANGE    0    ${tries}
        ${elementAppears}=    Run Keyword And Return Status    Page Should Contain Element    ${element}
        IF    '${shouldBeDisplayed}'=='true' and '${elementAppears}'=='False'
            Run Keywords    Sleep    ${timeout}    AND    Reload
        ELSE IF     '${shouldBeDisplayed}'=='false' and '${elementAppears}'=='True'
            Run Keywords    Sleep    ${timeout}    AND    Reload
        ELSE
            Exit For Loop
        END
    END
    IF    ('${shouldBeDisplayed}'=='true' and '${elementAppears}'=='False') or ('${shouldBeDisplayed}'=='false' and '${elementAppears}'=='True')
        Take Screenshot
        Fail    'Timeout exceeded, element state doesn't match the expected'
    END

Try reloading page until element does/not contain text:
    [Documentation]    will reload the page until an element text will be updated. The second argument is the expected condition (true[contains]/false[doesn't contain]) for the element text.
    [Arguments]    ${element}    ${expectedText}    ${shouldContain}    ${tries}=20    ${timeout}=1s
    FOR    ${index}    IN RANGE    0    ${tries}
        ${textAppears}=    Run Keyword And Return Status    Element Text Should Be    ${element}    ${expectedText}
        IF    '${shouldContain}'=='true' and '${textAppears}'=='False'
            Run Keywords    Sleep    ${timeout}    AND    Reload
        ELSE IF     '${shouldContain}'=='false' and '${textAppears}'=='True'
            Run Keywords    Sleep    ${timeout}    AND    Reload
        ELSE
            Exit For Loop
        END
    END
    IF    ('${shouldContain}'=='true' and '${textAppears}'=='False') or ('${shouldContain}'=='false' and '${textAppears}'=='True')
        Fail    'Timeout exceeded'
    END

Type Text When Element Is Visible
    [Arguments]    ${selector}    ${text}
    Run keywords
        ...    Wait Until Element Is Visible    ${selector}
        ...    AND    Type Text    ${selector}     ${text}
