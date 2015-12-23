# ScreenSaverManagement
To set minimum times for screen saver start, and require password

This script is invoked by a LaunchAgent.  It will make sure that the password is set and the minimum time is set on Screensavers.  The parameters are ediable at the top of the script.  As it runs as a root launch agent, it'll apply to anyone who uses the computer.  

If the user changes the password to something outside of policy, the script will change it back when it runs (which is I think is like every 300 seconds or so)
