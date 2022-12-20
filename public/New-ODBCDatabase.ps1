function New-ODBCDatabase
{
    <#
        .SYNOPSIS
            Create a new ODBC DB
        .DESCRIPTION
            This function will create a new Database on the server that you are 
            connected to.
        .PARAMETER Connection
            A connection object that represents an open connection to ODBC Server
        .PARAMETER Name
            The name of the database to create
        .EXAMPLE
            New-ODBCDatabase -Connection $Connection -Name "MyNewDB"

            Database
            --------
            mynewdb

            Description
            -----------
            This example creates the MyNewDB database on a ODBC server.
        .NOTES
            FunctionName : New-ODBCDatabase
            Created by   : jspatton
            Date Coded   : 02/11/2015 09:35:02
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/ODBC#New-ODBCDatabase
    #>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[ODBC.Data.ODBCClient.ODBCConnection]$Connection = $ODBCConnection
	)
	begin
	{
		$Query = "CREATE DATABASE $($Name);";
	}
	process
	{
		try
		{
			Invoke-ODBCQuery -Connection $Connection -Query $Query -ErrorAction Stop
			Get-ODBCDatabase -Connection $Connection -Name $Name
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}