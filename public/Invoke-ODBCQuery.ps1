function Invoke-ODBCQuery
{
    <#
        .SYNOPSIS
            Run an ad-hoc query against a ODBC Server
        .DESCRIPTION
            This function can be used to run ad-hoc queries against any ODBC Server. 
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
            Invoke-ODBCQuery -Connection $Connection -Query "INSERT INTO foo (Name) VALUES ('Dog'),('Treats');"

            Description
            -----------
            Add data to a sql table
        .NOTES
            FunctionName : Invoke-ODBCQuery
            Created by   : rwtaylor
            Date Coded: 12/20/2022 23:33:00
        .LINK
            https://github.com/thecrystalcross/ODBC
    #>
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Query,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[System.Data.Odbc.OdbcConnection]$Connection = $ODBCConnection
	)
	begin
	{
	}
	Process
	{
		try
		{
			
			[System.Data.Odbc.OdbcCommand]$command = New-Object System.Data.Odbc.OdbcCommand
			$command.Connection = $Connection
			$command.CommandText = $Query
			[System.Data.Odbc.OdbcDataAdapter]$dataAdapter = New-Object System.Data.Odbc.OdbcDataAdapter($command)
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