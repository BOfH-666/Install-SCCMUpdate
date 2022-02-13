# Install-SCCMUpdate  
  
**.SYNOPSIS**  
Installs ALL in SCCM Software Center available updates on one or more specified computers.  
  
**.DESCRIPTION**  
The Install-SCCMUpdate cmdlet will start the installation process of ALL in SCCM Software Center available updates for one or more specified computers.  
  
**.PARAMETER  ComputerName**  
One or more computernames  
  
**.PARAMETER  Credential**  
A credential object representing an account with adminstrative rights to the targeted computer.  
  
**.PARAMETER  ExcludeArticleID**  
A comma separated list of article IDs excluded from installation.  
  
#### .EXAMPLE 1  

```Powershell
PS C:\> Install-SCCMUpdate
```
  
This will start the installation process of all in SCCM Software Center available updates on the local computer.  
  
#### .EXAMPLE 2  

```Powershell
PS C:\> Install-SCCMUpdate -ComputerName 'RemoteComputer01','RemoteComputer02'
```
  
This will start the installation process of all in SCCM Software Center available updates on both specified computers  
  
#### .EXAMPLE 3  

```Powershell
PS C:\> $Cred = Get-Credential -UserName 'domain\DomainAdmin'  # ;-)
PS C:\> Install-SCCMUpdate -ComputerName 'DC_01','DC_02' -Credential $Cred
```
  
This will start the installation process of all in SCCM Software Center available updates on both specified domain controllers.  
  
#### .EXAMPLE 4  

```Powershell
PS C:\> Install-SCCMUpdate -ComputerName 'RemoteComputer37','RemoteComputer73' -Exclude 3012973
```
  
This will start the installation process of all in SCCM Software Center available updates on both specified computers except of the featureupdate for Windows 10 specified by its article ID.  
  
**.INPUTS**  
System.String, System.Management.Automation.PSCredential, System.Int  
  
**.OUTPUTS**  
Microsoft.Management.Infrastructure.CimMethodResult#CCM_SoftwareUpdatesManager#InstallUpdates  
  
**.NOTES**  
Author: O.Soyk  
Date:   20210120  
