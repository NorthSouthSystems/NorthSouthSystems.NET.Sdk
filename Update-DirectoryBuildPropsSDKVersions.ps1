param(
    [Parameter(Mandatory=$true)]
    [string]$RootDirectoryPath,

    [Parameter(Mandatory=$true)]
    [string]$NewVersion
)

$pattern = '<\s*Sdk\s+Name\s*=\s*"NorthSouthSystems\.NET\.Sdk"\s+Version\s*=\s*"(?<oldVersion>[^"]+)"\s*/>'

Get-ChildItem -Path $RootDirectoryPath -Recurse -File -Filter 'Directory.Build.props' -ErrorAction Stop | ForEach-Object {
    $file = $_.FullName
    Write-Host "Found: $file"

    $oldText = Get-Content -Raw -Path $file

    $newText = [regex]::Replace(
        $oldText,
        $pattern,
        [System.Text.RegularExpressions.MatchEvaluator]{
            param($match)

            $oldVersion = $match.Groups['oldVersion']

            return $match.Value.Replace($oldVersion.Value, $NewVersion)
        })

    if ($newText -ne $oldText) {
        Write-Host "    Updating: $file"
        Set-Content -Path $file -Value $newText -Encoding UTF8 -NoNewline
    } else {
        Write-Host "    Skipping: $file"
    }
}