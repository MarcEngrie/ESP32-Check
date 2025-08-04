$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path

### you must have python installed as well as esptool.py 

### if none of these are on your computer 
### download and install python from https://www.python.org/downloads/
### next run, in CMD window, the command 
###    pip install esptool
### or
###    pip3 install esptool
### or
###    python -m pip install esptool

### if you used the installation as above
$command_info  = 'python -m esptool flash_id'
$command_erase = 'python -m esptool --chip auto erase_flash'

### if you have PlatformIO installed, you might use it like this
# $userProfile = $env:USERPROFILE
# $esptoolPath = '\.platformio\packages\tool-esptoolpy'
# $command_info  = 'python ' + $userProfile + $esptoolPath + '\esptool.py flash_id'
# $command_erase = 'python ' + $userProfile + $esptoolPath + '\esptool.py --chip auto erase_flash'


### get info
Write-Host "`r`n`r`nGetting info from connected ESP32, be patient ... `r`n"
$lines = Invoke-Expression $command_info

### only for test/debug purposes
# foreach ($line in $lines)
# {
    # # Write-Host $line
# }

# if we got a feedback
if (-not [string]::IsNullOrEmpty($lines))
{
	# check if the feedback is what we expect it should be
	if ($lines -match 'Uploading stub') 
	{

		# Extract the target line: Chip ...
		$chip  = $lines -split "`n" | Where-Object { $_ -like "*Chip is*" }
		$chip  = $chip -replace "^Chip is ", ""
		$fil1  = ($chip -replace "\s*\([^)]*\)\s*", "").Trim()
		$ch    = "Chipset    : " + $chip
		Write-Host $ch

		# Extract the target line: frequency
		$speed = $lines -split "`n" | Where-Object { $_ -like "*Crystal*" }
		$speed = $speed -replace "^Crystal is ", ""
		$sp    = "Frequency  : " + $speed
		Write-Host $sp

		# Extract the target line: Flash
		$flash = $lines -split "`n" | Where-Object { $_ -like "*Detected flash size:*" }
		$flash = $flash -replace "^Detected flash size: ", ""
		$fil2  = $flash.Trim()
		$fl    = "Flash size : " + $flash
		Write-Host $fl

		# Extract the target line: Features
		$feat  = $lines -split "`n" | Where-Object { $_ -like "*Features*" }
		$feat  = $feat -replace "^Features: ", ""
		$ft    = "Features   : " + $feat
		Write-Host $ft

		# Extract the target line: mac
		# Check if any string contains "BASE MAC"
		$containsBaseMac = $lines -split "`n" | Where-Object { $_ -match "BASE MAC" }
		if ($containsBaseMac) 
		{
			$mac   = $lines -split "`n" | Where-Object { $_ -like "*BASE MAC:*" }
			$mac   = $mac -replace "^BASE MAC: ", ""
		} 
		else 
		{
			$mac   = $lines -split "`n" | Where-Object { $_ -like "*MAC:*" }
			$mac   = $mac -replace "^MAC: ", ""
		}
		$fil3  = ($mac  -replace ":", "").ToUpper()
		$mc    = "MAC address: " + $mac.ToUpper()
		Write-Host $mc

		# makesure folder exists
		$folderPath = $scriptDir + "\Devices_Owned\"
		if (-not (Test-Path -Path $folderPath -PathType Container)) 
		{
			New-Item -Path $folderPath -ItemType Directory
		}
		
		# write info to a file for later reference
		$outfile = $scriptDir + "\Devices_Owned\" + $fil1 + "_" + $fil2 + "_" + $fil3 + ".txt"

		$ch | Out-File -FilePath $outfile
		$sp | Out-File -FilePath $outfile -Append
		$fl | Out-File -FilePath $outfile -Append
		$ft | Out-File -FilePath $outfile -Append
		$mc | Out-File -FilePath $outfile -Append
		
		# ask if ESP32 needs to be erased
		do 
		{
			# ask but if no answer after 5 sec, erase anyway
			Write-Host -NoNewLine "`r`n`r`nDo you want to erase the" $chip "? (Y/N) [Auto-YES in 5 seconds]"

			$stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
			$response = $null

			while ($stopWatch.Elapsed.TotalSeconds -lt 5) 
			{
				if ([System.Console]::KeyAvailable) 
				{
					$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
					$response = ($key.Character).ToString().ToLower()
					break
				}
				Start-Sleep -Milliseconds 100
			}

			Write-Host ""

			switch ($response) 
			{
        {$_ -eq 'y' -or $_ -eq  $null}
				{
          Write-Host "Erasing in progress..."
					$lines   = Invoke-Expression $command_erase
					
					# for testing/debugging only
					# foreach ($line in $lines)
					# {
						# Write-Host $line
					# }
					
					if ($lines -match 'Chip erase completed successfully') 
					{
						Write-Host "`r`n`r`n$chip is erased`r`n"
						break
					}
					else
					{
						foreach ($line in $lines)
						{
							Write-Host $line
						}
		
						Write-Host "`r`n`r`nFYI: You might try this`r`n"
						Write-Host "`r`nWhen using this script, hold the BOOT button down"
						Write-Host "`r`n and keep it down while you run it" 
						Write-Host "`r`n"
					}
        }
				
				{$_ -eq 'n'} 
				{
            Write-Host "`r`n`r`n$chip not erased, as requested`r`n"
						break
        }
        
				default 
				{
            Write-Host "Invalid input. Please enter 'yes' or 'no'."
        }
			}
		} until ($response -eq 'yes' -or $response -eq 'n' -or $response -eq $null )
		
	}
	else
	{
		
		foreach ($line in $lines)
		{
			Write-Host $line
		}
		
		Write-Host "`r`n`r`nFYI: You might try this`r`n"
		Write-Host "`r`nWhen using this script, hold the BOOT button down"
		Write-Host "`r`n and keep it down while you run it" 
		Write-Host "`r`n"
		
	}
}
else
{
		
	Write-Host "`r`n`r`nNothinhg happened`r`n"
	Write-Host "`r`n`r`nFYI: You might try this`r`n"
	Write-Host "`r`nWhen using this script, hold the BOOT button down"
	Write-Host "`r`n and keep it down while it is running" 
	Write-Host "`r`n"
	
}

Write-Host -NoNewLine 'Press any key to continue...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
