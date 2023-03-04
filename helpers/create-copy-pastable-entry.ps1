<####
# To help with adding entries to the repo.
#
# 1. Follow the prompts.
# 2. Copy and paste the output into the repo's main README.md

####>

# Ask for the project URL
$url = Read-Host "Enter the project URL (e.g. https://github.com/myusername/myproject)"

# Remove trailing slash if it exists
$url = $url.TrimEnd('/')

# Ask for the commit hash or commit URL for the working project
$projectCommit = Read-Host "Enter the commit hash or commit URL for the working project (e.g. abc1234 or https://github.com/myusername/myproject/commit/abc1234)"

# Ask for the commit hash or commit URL for the working WebUI
$webuiCommit = Read-Host "Enter the commit hash or commit URL for the working Automatic1111 WebUI (e.g. abc1234 or https://github.com/AUTOMATIC1111/stable-diffusion-webui/commit/abc1234)"

# Extract the commit hash from the end of the GitHub commit URL
function ExtractCommitHash($commitUrl) {
    $pattern = "(?<=/commit/)[a-f0-9]{40}"
    $match = [regex]::Match($commitUrl, $pattern)
    if ($match.Success) {
        return $match.Value
    }
    else {
        return $commitUrl
    }
}

$webuiCommitHash = ExtractCommitHash($webuiCommit)
$projectCommitHash = ExtractCommitHash($projectCommit)

# Output the markdown text
Write-Host -ForegroundColor Yellow "`nPaste the following into the repo:`n"

Write-Host -fore cyan "## $url"
Write-Host -fore cyan "<details>"
Write-Host -fore cyan "<summary>tested with: (Click to expand:)</summary>"
Write-Host -fore cyan ""
Write-Host -fore cyan "- [WebUI ``$webuiCommitHash``](https://github.com/AUTOMATIC1111/stable-diffusion-webui/tree/$webuiCommitHash)" 
Write-Host -fore cyan "- [Extension ``$projectCommitHash``]($url/tree/$projectCommitHash)"
Write-Host -fore cyan "</details>"
