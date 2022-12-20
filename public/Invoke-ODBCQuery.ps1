function Invoke-ODBCQuery
{
    <#
        .SYNOPSIS
            Run an ad-hoc query against a ODBC Server
        .DESCRIPTION
            This function can be used to run ad-hoc queries against a ODBC Server. 
            It is also used by nearly every function in this library to perform the 
            various tasks that are needed.
        .PARAMETER Connection
            A connection object that represents an open connection to ODBC Server
        .PARAMETER Query
            A valid ODBC query
        .EXAMPLE
            Invoke-ODBCQuery -Connection $Connection -Query "CREATE DATABASE sample_tbl;"

            Description
            -----------
            Create a table
        .EXAMPLE
            Invoke-ODBCQuery -Connection $Connection -Query "SHOW DATABASES;"

            Database
            --------
            information_schema
            mynewdb
            ODBC
            performance_schema
            test
            testing
            wordpressdb
            wordpressdb1
            wordpressdb2

            Description
            -----------
            Return a list of databases
        .EXAMPLE
            Invoke-ODBCQuery -Connection $Connection -Query "INSERT INTO foo (Name) VALUES ('Bird'),('Cat');"

            Description
            -----------
            Add data to a sql table
        .NOTES
            FunctionName : Invoke-ODBCQuery
            Created by   : jspatton
            Date Coded   : 02/11/2015 11:09:26
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/ODBC#Invoke-ODBCQuery
    #>
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Query,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[ODBC.Data.ODBCClient.ODBCConnection]$Connection = $ODBCConnection
	)
	begin
	{
		$ErrorActionPreference = 'Stop'
	}
	Process
	{
		try
		{
			
			[ODBC.Data.ODBCClient.ODBCCommand]$command = New-Object ODBC.Data.ODBCClient.ODBCCommand
			$command.Connection = $Connection
			$command.CommandText = $Query
			[ODBC.Data.ODBCClient.ODBCDataAdapter]$dataAdapter = New-Object ODBC.Data.ODBCClient.ODBCDataAdapter($command)
			$dataSet = New-Object System.Data.DataSet
			$recordCount = $dataAdapter.Fill($dataSet)
			Write-Verbose "$($recordCount) records found"
			$dataSet.Tables.foreach{$_}
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}