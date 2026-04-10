<#
    .SYNOPSIS
        Name: Import-CSV-PRTG.ps1
        Adding device to PRTG from an CSV file
        
    .DESCRIPTION
        Adding device to PRTG from a CSV file

    .NOTES
        Release Date: 10TH of april 2026
    
        Made BY Qwereleros

    .NOTES
        This script require the modules :
            - PrtgApi https://github.com/lordmilko/PrtgAPI
#>

#Import CSV PRTG
#Download the PRTGAPI MODULE WITH
#Install-Module -Name PrtgAPI
import-module PrtgAPI
Get-Command Connect-PrtgServer
#-----------------------------------------------------------------------------------------------------------------------------
$CSV=Import-Csv  "PATH TO YOUR CSV FILE"-Delimiter ";" 

$PRTGurl = "PRTG URL"
$PRTGuser = "prtgadmin"
$PRTGpasswd = "prtgadmin"
$nameprobe = "Local Probe"
$CreationTime = "5"
#-----------------------------------------------------------------------------------------------------------------------------
#vragen als jij een groep wilt aanmaken
$loop = $true
while ($loop -eq $true){
    Clear-Host
    write-host "Do you want to make an new group?(Y)"
    Write-host "Do you want to use an exising group?(N)"
    Write-host "Do you want to use the groups from the CSV file(CSV)"
    $Question_Groupcreation = Read-Host "Y/N/CSV"
    
    if ($Question_Groupcreation -eq "y"){
        $loop = $false
        $CSVgroups = $false
    }
    elseif ($Question_Groupcreation -eq "n") {
        $loop = $false 
        $CSVgroups = $false 
    }
    elseif ($Question_Groupcreation -eq "csv") {
        $loop = $false 
        $CSVgroups = $true  
    }
}

#-----------------------------------------------------------------------------------------------------------------------------
#Connecting with PRTG
$ConnectPRTG = Connect-PrtgServer "$prtgurl" -Credential (New-Object System.Management.Automation.PSCredential("$PRTGuser", ("$PRTGpasswd" | ConvertTo-SecureString -AsPlainText -Force))) -Force
$ConnectPRTG

start-sleep -Seconds 5

#getting all the groups from PRTG
$allgroups = Get-group
#-----------------------------------------------------------------------------------------------------------------------------
#Making a new group if $question_groupcreation -eq Y
$loop = $true
if ($Question_Groupcreation -eq "y"){
    while ($loop -eq $true){
    
        Clear-Host
        
        Write-host "Don't use any special character and don't leave it empty"
        $Groupname = Read-host "What would you like to name your new group?"
        $Groupnamestatus= Get-Group $Groupname -ErrorAction SilentlyContinue

        #checking if the groupname is empty
        if ([string]::IsNullOrWhiteSpace($groupname)){ 
            Clear-host
            write-host "Don't leave your groupname empty"
            start-sleep -Second "1"
            continue
        }

        #checking if an other group has the same name
        if ($Groupnamestatus.Status -eq "Up"){       
            Write-host "Group $Groupname allready exists" 
            start-sleep -Second "1"
            continue
        }

        #checking for special characters
        if ($Groupname -match '[^a-zA-Z0-9]'){
            write-host "Don't use any special characters"
            start-sleep -Second "1"
            continue
        }
        else {
            $loop = $false
        }

        #making the group
        if (-not $Groupnamestatus){ 
            Get-probe "$nameprobe" | add-group $Groupname
        }
    }  
}


#-----------------------------------------------------------------------------------------------------------------------------
#choosing an existing group
if ( $Question_Groupcreation -eq "n" ){

    $loop = $true

    while ($loop -eq $true){

        Clear-Host

        Get-Group| Format-Table -AutoSize
        $Groupname = read-host "Which group do you want to choose?" 

        if ("$Groupname" -cin $allgroups.Name){
            $loop = $false
        }
        else {
            write-host "Spellings error type the group again" -ForegroundColor Red
            write-host "The Script is caseletter sensitive"
            start-sleep -second "1"
        }
    }
}
#-----------------------------------------------------------------------------------------------------------------------------
#Checking if there are no empty spaces in the CSV file and if the group exist.
Write-host "CSV file is getting checked" -foregroundcolor green

if ( $Question_Groupcreation -eq "csv" -or $Question_Groupcreation -eq "y" -or $Question_Groupcreation -eq "n"){
    Clear-Host
    foreach ($check_Devices in $CSV){ 

        $Devicename = $check_Devices.DeviceName.trim()
        $ip         = $check_Devices.IP.trim()
        $Groupname  = $check_Devices.Groupname.trim()

        #checken als Devicename is leeg
        if (-not "$Devicename"){
            Write-Host "There is no Devicename in the CSV file for the ip: ($ip)" -ForegroundColor Yellow
        }
        if ( $Question_Groupcreation -eq "csv"){
            #checking if $groupname is empty
            if (-not "$Groupname"){
                Write-Host "There is no Groupname in the CSV file for the ip/Devicename: ($ip),($Devicename)" -ForegroundColor Yellow
            }

            #checking if the group exist
            if ($check_Devices.Groupname -notin $allgroups.Name){
                write-host "No groupname found $Groupname in PRTG" -foregroundcolor yellow
                continue
            }
        }
        
    }

   
    $loop = $true
    While ($Loop -eq $true){

        write-host "Do you want to continue with the script? (Y)"
        Write-host "Do you want to stop the script?(N)"
        Write-host "Devices without devicename or groupname will nog be created"
        Write-host "Devices withou ip will be made"
        $Question_Continuescript = read-host "Y/N"

        if ($Question_Continuescript -eq "y"){

            $Loop = $false
        }
        elseif ($Question_Continuescript -eq "n") {
            Exit
        }
        else {
            continue
        }
    }
}
#-----------------------------------------------------------------------------------------------------------------------------
$loop = $true
while ($loop -eq $true){
    Clear-Host
    write-host "Do you want to add all the sensors yourself?(zelf)" 
    write-host "Do you want to use an Template?(Template)"
    write-host "Do you want to use only ping?(ping)" #for this to work you need an template with only ping and change it here in the script to your template
    write-host "Do you want to add all the sensors with autodiscovery?(auto)"
    $Question_CreationType = Read-host " zelf/Template/ping/auto"  

    if ($Question_CreationType -in @("zelf","Template","ping","auto")){
        $loop = $false
    }
}
#-----------------------------------------------------------------------------------------------------------------------------
#Asking which template you want to use
if ($Question_CreationType -eq "Template"){
    Clear-Host
    $loop = $true 
    $DeviceTemplates= Get-DeviceTemplate 
    while ($loop -eq $true) {
        Clear-Host
        Get-DeviceTemplate|select-object name |format-table -autosize 
        $Template = Read-host "Which template do you want to use?"
        if ($Template -in $DeviceTemplates.Name){
            $loop = $false
        }
    }
}
#-----------------------------------------------------------------------------------------------------------------------------
Clear-Host
foreach ($Device in $csv){
    
    if ($CSVgroups -eq $true){
        $Groupname = $Device.Groupname
    }
    #Devices without device or groupname are getting skipped
    if ([string]::IsNullOrWhiteSpace($Device.Devicename) -or [string]::IsNullOrWhiteSpace($Device.Groupname)){
        continue
    }
    if ($Device.Groupname -notin $allgroups.Name){
        continue
    }
    

   #debug info
   write-host "Device = $($Device.DeviceName)" -ForegroundColor Yellow
   Write-Host "IP = $($Device.IP)" -ForegroundColor Yellow
   Write-Host "Groep = $($Device.Groupname)" -ForegroundColor Yellow

    #making devices
    Switch($Question_CreationType){
        'zelf'{
            
            Write-host Device $Device.DeviceName is now being added
            Start-Sleep -Seconds $CreationTime
            Clear-Host
            Get-Group "$Groupname" | where-object {$_.Name -ceq $Groupname} | Add-Device $Device.DeviceName $Device.IP
        }   
        
        'Template' {  
            Write-host Device $Device.DeviceName is now being added
            Start-Sleep -Seconds $CreationTime
            Clear-Host
            Get-Group "$Groupname" | where-object {$_.Name -ceq $Groupname} | Add-Device $Device.DeviceName $Device.IP -autodiscover -Template "$Template"
        }

        'ping' { 
                Write-host Device $Device.DeviceName is now being added
                Start-Sleep -Seconds $CreationTime
                Clear-Host
                Get-Group "$Groupname" | where-object {$_.Name -ceq $Groupname} | Add-Device $Device.DeviceName $Device.IP -autodiscover -Template "ping only"
        }
        
        'auto'{
                Write-host Device $Device.DeviceName is now being added
                Start-Sleep -Seconds $CreationTime
                Clear-Host
                Get-Group "$Groupname" | where-object {$_.Name -ceq $Groupname} | Add-Device $Device.DeviceName $Device.IP -autodiscover
        }
        'default' { write-host "Choice does not match one of the four options . Pleasy type it again"}
    }
}
    

Write-host "All Devices have been added" -ForegroundColor Yellow
Write-host "If you cant find your added devices refresh your page" -ForegroundColor yellow
Disconnect-PrtgServer
