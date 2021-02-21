# plexscripts

Just a repository of my scripts used along with my Plex server
  
 Check-PlexTuner.Ps1
  Purpose:
    Check if the Plex tuner service is running. If not, check if plex is active and restart Plex if it is idle.
    
  Usage: 
    Run Check-PlexTuner.ps1 from Powershell
  
  Arguments:
  -CheckForActivity
    Include if you want the script to check if Plex is playing or recording before a restart. You must set -Token with a valid token for your account to use this
   
  -Token "YourPlexToken"
    Use to set your Plex token so the server status can be checked via the API
   
   -Protocol "http" or "https"
    Select which protocol to use when checking for activity. 
    default value = "http"
    
   -ServerIPorHost "IP or HostName"
    Set the IP Address or HostName of your Plex Server
    
   -ServerPort PortNumber
    Set the port to use when connecting to your Plex Server
    default value = 32400
    
   -Timeout
    Seconds to wait for idle or for process to stop
    default value = 10
   
   -PlexPath
    Set the path to your plexe executable
    default value = "C:\Program Files (x86)\Plex\Plex Media Server\Plex Media Server.exe"
