*** Settings ***
Resource    ../../resources/common/common.robot
Suite Setup    SuiteSetup
Test Setup    TestSetup
Resource    ../../resources/steps/login_step.robot
Resource    ../../resources/common/common_win.robot


*** Test Cases ***
# login_funtionality
#     Login as a user:    ${user_email}    ${user_password}
#     Logout as a user
#     Pause Execution

test_win
    Open the application