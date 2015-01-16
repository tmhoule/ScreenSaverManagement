#!/bin/sh

#Todd Houle
#Partners Healthcare
#30Aug2014
#modified 23Sept2014
#To set screen saver to conform to policy


#======================CONSTANTS====SET=AS=NEEDED=======
#Minimum seconds for screen saver to be set to
#ok values are 60 (1min), 120 (2mins), 300 (5mins), 600 (10mins), 1200 (20mins), 1800 (30mins), 3600 (1hour)
minSSTime=600

#Require password?  YES,NO,TRUE,FALSE are acceptable
requirePW=1

#number of seconds for password to be required.
#ok values are 0 (immediatly), 5, 60, 300 (5mins), 900 (15mins), 3600 (1 hour), 14400 (4 hours)
minPWTime=5
#=========================================================


#get required info
whoami=`whoami`
uuid=`system_profiler SPHardwareDataType |grep "Hardware UUID"|awk '{print $3}'`
os_vers=`sw_vers -productVersion|awk -F. '{print $2}'`

#set off by default
usePlist=""

if [ "$os_vers" -gt "7" ]; then
    usePlist=".plist"
fi

#create defaults if file doesn't exist
if [ ! -f /Users/$whoami/Library/Preferences/ByHost/com.apple.screensaver.$uuid.plist ]; then
    `defaults write /Users/$whoami/Library/Preferences/ByHost/com.apple.screensaver.$uuid$usePlist idleTime -int $minSSTime`
fi

if [ ! -f /Users/$whoami/Library/Preferences/com.apple.screensaver.plist ]; then
#    `defaults write /Users/$whoami/Library/Preferences/com.apple.screensaver$usePlist askForPassword -int $requirePW`
    osascript -e 'tell application "System Events" to set require password to wake of security preferences to true'
    `defaults write /Users/$whoami/Library/Preferences/com.apple.screensaver$usePlist askForPasswordDelay -int $minPWTime`
fi

#get Current Settings
currentSSidle=`defaults read /Users/$whoami/Library/Preferences/ByHost/com.apple.screensaver.$uuid$usePlist idleTime`
currentLockSetting=`defaults read /Users/$whoami/Library/Preferences/com.apple.screensaver$usePlist askForPassword 1`
currentLockTime=`defaults read /Users/$whoami/Library/Preferences/com.apple.screensaver$usePlist askForPasswordDelay`


#verify Current Settings
re='^[0-9]+$'
if ! [[ $currentSSidle =~ $re ]] ; then
#    logger "invalid idleTime key: setting to default"
    `defaults write /Users/$whoami/Library/Preferences/ByHost/com.apple.screensaver.$uuid$usePlist idleTime -int $minSSTime`
    currentSSidle=$minSSTime
fi

if ! [[ $currentLockSetting =~ $re ]] ; then
#    logger "invalid LockSetting key: setting to default"
#    `defaults write /Users/$whoami/Library/Preferences/com.apple.screensaver$usePlist askForPassword -int $requirePW`
    osascript -e 'tell application "System Events" to set require password to wake of security preferences to true'
    currentLockSetting=$requirePW
fi

if ! [[ $currentLockTime =~ $re ]] ; then
#    logger "invalid PasswordIdleTime key: setting to default"
    `defaults write /Users/$whoami/Library/Preferences/com.apple.screensaver$usePlist askForPasswordDelay -int $minPWTime`
    currentLockTime=$minPWTime
fi


#logger "Checking settings now"
#Compare current settings
#if currently less than the minimum, set to $minSSTime
if [ $currentSSidle -gt $minSSTime ] || [ $currentSSidle -eq 0  ]; then
    `defaults write /Users/$whoami/Library/Preferences/ByHost/com.apple.screensaver.$uuid$usePlist idleTime $minSSTime`
#    logger "Changed ScreenSaver Idle time from $currentSSidle to $minSSTime"
fi

#logger "checking pwlock setting"
#check password lock setting
if [ "$currentLockTime" -gt  "$minPWTime" ]; then
    `defaults write /Users/$whoami/Library/Preferences/com.apple.screensaver$usePlist askForPasswordDelay -int $minPWTime`
#    logger "Changed Password Lock delay from $currentLockTime to $minPWTime"
fi

#logger "checking other lock setting"
#check password lock is set by rules.
if [ "$requirePW" = "1" ];then
    if [ "$currentLockSetting" -ne "1" ]; then
#	`defaults write /Users/$whoami/Library/Preferences/com.apple.screensaver$usePlist askForPassword -int $requirePW`
	osascript -e 'tell application "System Events" to set require password to wake of security preferences to true'
#	logger "Changed lock setting from $currentLockSetting to $requirePW"
    fi
fi

#logger "finished"
if [ "$os_vers" -gt "7" ]; then
    `/usr/bin/killall SystemUIServer`
fi
