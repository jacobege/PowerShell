## general ##

if ($host.Name -eq 'ConsoleHost') {
    Import-Module PSReadLine
    Set-PSReadLineKeyHandler -Key Tab -Function Complete
}

function OpenCurrentDirectory {
    ii (Get-Location).Path
}

## git specific ##

function RebaseOnMaster {
    git fetch origin master
    git rebase origin/master
}

function PLERebase {
    git fetch origin # Fetches all remote changes to the local master
    git push . origin/master:master # Does some PLE magic, but i think it updates the local master
    git rebase master # Rebases the current branch onto master
    # After this You should be able to push the branch... Should...
}

function PLEPushCurrentBranch {
    $CurrentGitBranch = git branch --show-current

    git push --force-with-lease origin $CurrentGitBranch

    if (!$?) {
        git push --set-upstream origin $CurrentGitBranch
    }
}

function PushCurrentBranch {
    git push

    if (!$?) {
        $CurrentGitBranch = git branch --show-current
        git push --set-upstream origin $CurrentGitBranch
    }
}

## apex specific ##

$apexDir = 'C:\development\Schultz.Apex'
$feDir = $apexDir + '\src\clients\jobcenter-desktop\jobcenter-desktop-frontend'

function GoToApex {
    cd $apexDir
}

function GoToApexFrontEnd {
    cd $feDir
}

function Start-Apex {
    Push-Location ($apexDir + '\local-runtime')
    
    .\run-tasks.ps1 jdc;
    .\run-tasks.ps1 fasit-search-indexer-service;
    .\run-tasks.ps1 fasit-search-reindexer-service;
    .\run-tasks.ps1 fasit-search-triggeroutbox-service
    
    Pop-Location
}

function Start-LocalSetup {
    Push-Location $apexDir

    .\local-setup.ps1

    Pop-Location
}

function ColdStart-Apex {
    Start-LocalSetup
    Start-Apex
}

function JestTest {
    Push-Location $feDir

    yarn test

    Pop-Location
}

function AddMigration {
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $MigrationName
    )

    Push-Location ($apexDir + '\src\fasit-interview')

    dotnet ef migrations add $MigrationName -c InterviewDbContext -s Fasit.Interview.Service -o DataAccess/Migrations

    Pop-Location
}

function UpdateDatabase {
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $MigrationName
    )

    Push-Location ($apexDir + '\src\fasit-interview\Fasit.Interview.Service')

    dotnet ef database update $MigrationName

    Pop-Location
}