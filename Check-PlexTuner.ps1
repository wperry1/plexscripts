param(
[string]$Token,
[ValidateSet("http", "https")]
[string]$Protocol = "http",
[string]$ServerIPorHost = "127.0.0.1",
[int]$ServerPort = 32400,
[int]$Timeout = 10,
[switch]$CheckForActivity,
[string]$PlexPath = "C:\Program Files (x86)\Plex\Plex Media Server\Plex Media Server.exe"
)

function Get-PlexActive{
    $active = $false
    
    ### Check if antything is playing ###
    $url = "{0}://{1}:{2}/status/sessions?X-Plex-Token={3}" -f $Protocol,$ServerIPorHost,$ServerPort,$token
    $result = Invoke-RestMethod -uri $url
    if($result.MediaContainer.Size -notlike "0"){ $active = $true }

    ### If nothing is playing, check if anything is recording ###
    if(!$active){
        $url = "{0}://{1}:{2}/media/subscriptions/scheduled?X-Plex-Token={3}" -f $Protocol,$ServerIPorHost,$ServerPort,$token
        $result = Invoke-RestMethod -uri $url
        $inprog = $result.MediaContainer.MediaGrabOperation | WHERE status -eq "inprogress" | ft -AutoSize
        if($inprog){ $active = $true }
    }

    ### Return the active state
    return $active
}

### Get the Plex Update Service, PMS Process, and Tuner Service Process
$srvPlex = Get-Service "PlexUpdateService"
$prcPlex = Get-Process "Plex Media Server"
$prcTune = Get-Process "Plex Tuner Service" -ErrorAction SilentlyContinue

### If the Tuner service is not running, startthe process of restarting it
if(!($prcTune)){
    
    Write-Host "Tuner is not running."
    
    if($CheckForActivity){
        $startTime = Get-Date
        Write-Host " - Checking if media is playing..."
        ### Check every second for $Timeout seconds for Plex to be idle
        while( Get-PlexActive -and ((get-date) - $startTime).TotalSeconds -lt $Timeout ){
            Write-Host "   - Waiting for Plex to be Idle..."
            Start-Sleep -Seconds 1
        }
    }
    Write-Host " - Ending Process Gracefully..."
    $stopStart = Get-Date
    $prcPlex | Stop-Process
    while(($prcPlex | Get-Process -ErrorAction SilentlyContinue) -and ( ((Get-Date) - $stopStart).TotalSeconds -le $timeout )){ Start-Sleep -Milliseconds 100 }

    $stopStart = Get-Date
    if($prcPlex | Get-Process -ErrorAction SilentlyContinue){ 
        Write-Host " - Graceful termination failed, force quitting Plex Process..."
        $prcPlex | Get-Process | Stop-Process -Force 
    }
    while(($prcPlex | Get-Process) -and ( ((Get-Date) - $stopStart).TotalSeconds -le $timeout )){ Start-Sleep -Milliseconds 100 }

    Start-Process -FilePath $PlexPath
    Start-Sleep -Seconds 1
}
else{ Write-Host "Tuner is running" }

Get-Process plex*
