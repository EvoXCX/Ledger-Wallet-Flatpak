*** Settings ***
Documentation    X11 tests for Ledger Live Flatpak (Electron/Zypak)
Library          Process
Library          OperatingSystem
Library          String
Library          Collections
Suite Setup      Setup Environment
Suite Teardown   Cleanup Environment

*** Variables ***
${APP_ID}             com.ledger.ledgerwallet
${BUNDLE}             Ledger-Wallet.flatpak
${DISPLAY}            :99
${STARTUP_TIMEOUT}    45s
${UI_TIMEOUT}         45s
${LOG_GRACE}          20s
${STDOUT_LOG}         ${TEMPDIR}${/}ledger-live-stdout.log
${STDERR_LOG}         ${TEMPDIR}${/}ledger-live-stderr.log

*** Keywords ***
Setup Environment
    Log    === Using CI-provided DBus/X11 ===
    ${dbus}=    Get Environment Variable    DBUS_SESSION_BUS_ADDRESS
    Should Not Be Empty    ${dbus}
    ${disp}=    Get Environment Variable    DISPLAY    default=
    ${xdg}=     Get Environment Variable    XDG_RUNTIME_DIR    default=
    Log    DISPLAY=${disp} XDG_RUNTIME_DIR=${xdg}
    Set Environment Variable    ELECTRON_OZONE_PLATFORM_HINT    x11
    Set Environment Variable    ELECTRON_ENABLE_WAYLAND    0
    Set Environment Variable    GDK_BACKEND    x11

Cleanup Environment
    Log    Cleaning up processes...
    Terminate All Processes    kill=True

Install App (Idempotent)
    Log    === Installing Flatpak App (idempotent) ===
    ${exists}=    Run Process    test    -f    ${BUNDLE}
    Should Be Equal As Integers    ${exists.rc}    0
    ${rem}=    Run Process    flatpak    remotes    --user    --columns    name
    ${fl_missing}=    Evaluate    'flathub' not in """${rem.stdout}"""
    IF    ${fl_missing}
        Run Process    flatpak    remote-add    --user    --if-not-exists    flathub    https://dl.flathub.org/repo/flathub.flatpakrepo
    END
    ${info}=    Run Process    flatpak    info    --user    ${APP_ID}
    IF    ${info.rc} == 0
        Log    App already installed, skipping install
    ELSE
        ${res}=    Run Process    flatpak    install    --user    --noninteractive    ${BUNDLE}    stdout=PIPE    stderr=PIPE
        Should Be Equal As Integers    ${res.rc}    0
    END
    Log    === Installation OK ===

Wait Flatpak Sandbox
    Wait Until Keyword Succeeds    ${STARTUP_TIMEOUT}    2s    Flatpak App Should Be Running

Flatpak App Should Be Running
    ${ps}=    Run Process    flatpak    ps    stdout=PIPE    stderr=PIPE
    Should Be Equal As Integers    ${ps.rc}    0
    Should Contain    ${ps.stdout}    ${APP_ID}

Launch App (X11) And Capture Logs
    Log    === Launching App in X11 mode ===
    Run Keyword And Ignore Error    Remove File    ${STDOUT_LOG}
    Run Keyword And Ignore Error    Remove File    ${STDERR_LOG}

    ${handle}=    Start Process    flatpak    run    ${APP_ID}    alias=app    stdout=${STDOUT_LOG}    stderr=${STDERR_LOG}
    Set Suite Variable    ${APP_HANDLE}    app
    ${pid}=    Get Process Id    ${APP_HANDLE}
    Set Suite Variable    ${APP_PID}    ${pid}

    Wait Flatpak Sandbox
    Sleep    ${LOG_GRACE}

Assert CLI Logs Clean
    ${stderr}=    Get File    ${STDERR_LOG}
    ${stdout}=    Get File    ${STDOUT_LOG}
    ${stderr_lower}=    Convert To Lowercase    ${stderr}
    ${stdout_lower}=    Convert To Lowercase    ${stdout}
    Should Not Contain    ${stderr_lower}    fatal
    Should Not Contain    ${stderr_lower}    exception
    Should Not Contain    ${stderr_lower}    traceback
    Should Not Contain    ${stdout_lower}    exception
    Should Not Contain    ${stdout_lower}    traceback

*** Test Cases ***
X11 Full Flow
    Install App (Idempotent)
    Launch App (X11) And Capture Logs
    Assert CLI Logs Clean
