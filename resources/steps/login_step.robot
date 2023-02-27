*** Settings ***
Resource    ../common/common.robot
Resource    ../pages/login_page.robot

*** Keywords ***
Login as a user:
    [Arguments]    ${user_name}    ${password}
    Type Text    ${username_field_locator}    ${user_name}
    Type Text    ${user_password_locator}    ${password}
    Click    ${login_button_locator}
    Wait Until Element Is Visible    ${login_email_locator}
    
Logout as a user
    Click    ${user_menu_button_locator}
    Click    //a[contains(text(),'Logout')]
    Wait Until Element Is Visible    ${username_field_locator}