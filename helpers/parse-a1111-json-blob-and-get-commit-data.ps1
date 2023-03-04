<#	
	===========================================================================
	.DESCRIPTION
		To process JSON and get the current commits of the various repos
	
	Prerequisites
		Have git installed or at least in your PATH

	To Use:
		1. Copy the ENTIRE JSON blob from https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Extensions-index.
       from {"about" ALL the way to the end
		2. Paste into a file and save
		3. Edit the 'Configure these' section of script
		4. Run and follow the prompts
	
#>

############# Configure these #############

$gitPath = "C:\Program Files\Git\bin\git.exe"

# where you want the output to go
$csvPath = "C:\temp\converted_data.csv"

###########################################

# Verify if the Git executable is in the provided directory
if (-not (Test-Path $gitPath))
{
	Write-Warning "Git executable not found in the provided directory. Assuming Git is in the PATH."
	$gitPath = "git.exe"
}

# Prompt user for the path to the file containing the JSON string
$path = Read-Host "Please enter the path to the file containing the JSON string"
$jsonString = Get-Content -Path $path -Raw

# Convert the JSON string to a PowerShell object
$jsonObject = ConvertFrom-Json $jsonString

# Convert the PowerShell object back to JSON with indentation
$beautifiedJson = ConvertTo-Json $jsonObject -Depth 100 -Compress | ConvertFrom-Json | ConvertTo-Json -Depth 100

# Output the beautified JSON
#Write-Output $beautifiedJson

$data = ConvertFrom-Json $beautifiedJson

$items = @()
foreach ($extension in $data.extensions)
{
	$tags = $extension.tags -join "`n"
	$item = [pscustomobject]@{
		Name = $extension.name
		URL  = $extension.url
		Description = $extension.description
		Added = $extension.added
		Tags = $tags
		Commit = $null
	}
	
	try
	{
		Invoke-WebRequest $item.URL -Method Head -ErrorAction SilentlyContinue |
		Select-Object -ExpandProperty Headers.'HTTP/1.1' -ErrorAction SilentlyContinue |
		Select-String '404' -Quiet
		
		# Call the git command to retrieve the latest commit
		$output = & $gitPath ls-remote $item.URL HEAD
		$commit = ($output -split '\s+')[0]
	}
	catch
	{
		# If an error occurs, set the commit to blank
		$commit = "Probably doesn't exist anymore"
	}
	
	# Add the commit to the current item
	$item.Commit = $commit
	
	# Output the item with the commit added
	#$item | Format-Table -AutoSize
	#$item | Export-Csv -Path $csvPath -NoTypeInformation -Append
	$item
	$items += $item
}

# Output the formatted table of all items
$items | Format-Table -AutoSize

# Export all items to a CSV file
$items | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host -fore Cyan "CSV file created in: $csvPath"

Read-host "Press Enter to close"
