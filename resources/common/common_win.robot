*** Settings ***
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
Library    RPA.Windows
Library    Browser
Library    RPA.Desktop

*** Variables ***
${env}    win_demo



*** Keywords ***
Open the application
    # Open Application    Calc.exe
    Windows Search    Code

        

