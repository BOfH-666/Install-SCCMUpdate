
<#
    .SYNOPSIS
        Installs ALL in SCCM Software Center available updates on one or more specified computers.
    .DESCRIPTION
        The Install-SCCMUpdate cmdlet will start the installation process of ALL in SCCM Software Center available updates for one or more specified computers.
    .PARAMETER  ComputerName
        One or more computernames
    .PARAMETER  Credential
        A credential object representing an account with adminstrative rights to the targeted computer.
    .PARAMETER  ExcludeArticleID
        A comma separated list of article IDs excluded from installation.
    .EXAMPLE
        PS C:\> Install-SCCMUpdate

        This will start the installation process of all in SCCM Software Center available updates on the local computer.
    .EXAMPLE
        PS C:\> Install-SCCMUpdate -ComputerName 'RemoteComputer01','RemoteComputer02'

        This will start the installation process of all in SCCM Software Center available updates on both specified computers
    .EXAMPLE
        PS C:\> $Cred = Get-Credential -UserName 'domain\DomainAdmin'
        PS C:\> Install-SCCMUpdate -ComputerName 'DC_01','DC_02' -Credential $Cred

        This will start the installation process of all in SCCM Software Center available updates on both specified domain controllers.
    .EXAMPLE
        PS C:\> Install-SCCMUpdate -ComputerName 'RemoteComputer37','RemoteComputer73' -Exclude 3012973

        This will start the installation process of all in SCCM Software Center available updates on both specified computers except of the featureupdate for Windows 10 specified by its article ID.
    .INPUTS
        System.String, System.Management.Automation.PSCredential, System.Int
    .OUTPUTS
        Microsoft.Management.Infrastructure.CimMethodResult#CCM_SoftwareUpdatesManager#InstallUpdates
    .NOTES
        Author: O.Soyk
        Date:   20210120
#>
function Install-SCCMUpdate {
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Enter one or more computer names separated by comma.")]
        [ValidateNotNullOrEmpty()]
        [Alias("CN", "MachineName", "Name", "Hostname")]
        [System.String[]]
        $ComputerName = $ENV:COMPUTERNAME,
        [Parameter(Position = 1,
            Mandatory = $false,
            HelpMessage = "A credential object granting access to the targeted remote computer.")]
        [System.Management.Automation.PSCredential]
        $Credential,
        [Parameter(Position = 2,
            Mandatory = $false,
            HelpMessage = "A comma separated list of articleIDs to exclude from installation")]
        [Alias("Exclude")]
        [int[]]
        $ExcludeArticleID = @()
            )
    process {
        if (Test-Connection -TargetName $ComputerName -Count 1 -TimeoutSeconds 1 -Quiet) {
            $NewPSSessionParams = @{
                ComputerName = $ComputerName
            }
            if ($Credential) {
                $NewPSSessionParams.Credential = $Credential
            }
            $PSSession = New-PSSession @NewPSSessionParams
            Invoke-Command -Session $PSSession -ScriptBlock {
                try {
                    $GetCimInstanceParams = @{
                        NameSpace   = 'ROOT\ccm\ClientSDK'
                        ClassName   = 'CCM_SoftwareUpdate'
                        Filter      = 'ComplianceState = 0'
                        ErrorAction = 'Stop'
                    }
                    $InvokeCimMethodParams = @{
                        Namespace   = 'ROOT\ccm\ClientSDK' 
                        ClassName   = 'CCM_SoftwareUpdatesManager'
                        MethodName  = 'InstallUpdates'
                        Arguments   = @{ 
                            CCMUpdates = [ciminstance[]](Get-CimInstance @GetCimInstanceParams | Where-Object -Property 'ArticleID' -NotIn -Value $USING:ExcludeArticleID) 
                        }
                        ErrorAction = 'Stop'
                    }
                    Invoke-CimMethod @InvokeCimMethodParams
                }
                catch {
                    throw $_
                    Write-Error -Message "PSSession error connecting computer '$($ComputerName)'"
                }
            }
            Remove-PSSession -Session $PSSession
        }
        else {
            Write-Warning -Message "Command  ""Test-Connection -TargetName '$($ComputerName)' -Count 1 -TimeoutSeconds 1 -Quiet""  failed"
        }
    }
}
