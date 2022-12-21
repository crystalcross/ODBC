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
            Created by   : rwtaylor
            Date Coded: 12/20/2022 23:33:00
        .LINK
            https://github.com/thecrystalcross/ODBC#New-ODBCDatabase
    #>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[System.Data.Odbc.OdbcConnection]$Connection = $ODBCConnection
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