@echo off
echo ========================================================
echo  DailyMart - ADB Port Forward for Mobile Testing (USB)
echo ========================================================
echo.
adb devices
echo.
adb reverse tcp:5000 tcp:5000
echo.
echo Active Reverse Rules:
adb reverse --list
echo.
echo ========================================================
echo Reverse connection active! 
echo Your phone can now connect to http://127.0.0.1:5000
echo ========================================================
pause

