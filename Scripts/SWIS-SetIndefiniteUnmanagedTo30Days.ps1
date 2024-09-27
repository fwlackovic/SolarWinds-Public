# Replace Line 4

$SwisUser = "SWQL"
$SwisHostname = ""
$SwisPasswordFile = "F:\Scripts\Credentials\SWQL-User.txt"

$SwisPassword = Get-Content $SwisPasswordFile | ConvertTo-SecureString
$Creds = New-Object System.Management.Automation.PSCredential $SwisUser,$SwisPassword

# Connect to SWIS
$SwisConnection = Connect-Swis -Hostname $SwisHostname -Credential $Creds

# Test SWIS Connection
$TestQuery = "SELECT TOP 10 Caption FROM Orion.Nodes"
$TestResults = Get-SwisData $SwisConnection $TestQuery

# Begin Script

$Swql = @"
    SELECT Caption
    , NodeId
    , UnmanagedUntil

    FROM Orion.Nodes

    WHERE Status = 9
    AND UnmanagedUntil = '9999-01-01 00:00:00'
"@

$SwqlResults = Get-SwisData $SwisConnection $Swql

$UnmanagedDate = (Get-Date).AddDays(30)

foreach ( $node in $SwqlResults ) {
    $CurrentDate = (Get-Date)

    Invoke-SwisVerb $SwisConnection Orion.Nodes Unmanage @(
        "N:$($node.NodeId)",
        $CurrentDate,
        $UnmanagedDate,
        $FALSE
    )
}