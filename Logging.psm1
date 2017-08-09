<#
.SYNOPSIS  
    Logging module to be used in any PS script
.DESCRIPTION
    Tool set to create and manage log files.

    new-logfile - create a new log file

    set-logfile - set active logfile

    write-log - add an entry to the active log

    get-currentlogcontents - display all contents of a log

    get-currentlog - show active log

.NOTES  
    File Name  : install-package.ps1
    Author     : Bryan Chen - bryan.chen0@gmail.com
    Requires   : Powershell 3.0 minumum
.LINK  

.EXAMPLE

    PS C:\temp\logs> new-logfile
    C:\temp\logs\testlog.log

    PS C:\temp\logs> set-logfile C:\temp\logs\testlog.log

    PS C:\temp\logs> get-logfile
    C:\temp\logs\testlog.log

    PS C:\temp\logs> write-log -message "test log line 1" -level Info -verbose
    test log line 1

    PS C:\temp\logs> write-log -message "test error log line 2" -level error -verbose
    test error log line 2

    PS C:\temp\logs> get-logfilecontent
    6/26/2017_05:25:24:Info - test log line 1
    6/26/2017_05:25:37:error - test error log line 2
#>


function new-logfile {
    param(
        [String]$logfile_path = $(get-location | select -ExpandProperty path), #uses current working dir if non specified
        [string]$logfile_name = "testlog.log",
        [string]$logfile,
        [switch]$set
    )
    #if $logfile not specified testlog.log is set to currentworking dir
    if(!$logfile){
        $logfile = "$logfile_path\$logfile_name"
    }

    if(!$(Test-Path $logfile)){
        try{
            New-Item -Path $logfile -Force -ErrorAction Stop | Out-Null
            #switch to also set the log file to the active log file
            if($set){
                set-logfile -logfile $logfile
            }
            return $logfile
        }catch{
            throw "unable to create log file:`n $($_.exception)"
        }
    }else{
        Write-Host "log file already exists"
    }
}
 #set log file to active log file
function set-logfile{
    Param(
        [string]$logfile
    )

    if(!$(Test-Path $logfile)){
 
       throw "logfile does not exist"

    }else{
        $Global:gl_logfile = $logfile
    }

}

#write a log entry into the log file
function write-log {
param(
    [String]$message,
    [validateset("Info","Warning","Error")]
    [String]$level,
    [Switch]$verbose
)
    if(!$(test-path $Global:gl_logfile)){
    
        throw "unable to find log file - Create-logfile then Set-Logfile"
    }
    "$(Get-Date -Format M/d/yyyy_hh:mm:ss):$level - $message" | Out-File -Append $Global:gl_logfile 
    if($verbose){
        Write-Output $message
    }

}

#display active log contents
function get-logfilecontent {
    if($Global:gl_logfile){return $(Get-Content $Global:gl_logfile)}
    else{Write-Host "no active log file set"}
}

#display active log
function get-logfile{

    if($Global:gl_logfile){return $Global:gl_logfile}
    else{Write-Host "no active log file set"}
}