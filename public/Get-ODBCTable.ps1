function Get-ODBCTable
{
    <#
        .SYNOPSIS
            Get a list of one or more tables on a database
        .DESCRIPTION
            This function will return one or more tables on a database.
        .PARAMETER Connection
            A connection object that represents an open connection to ODBC Server
        .PARAMETER Database
            The name of the database to get tables from
        .PARAMETER Table
            The name of the table to get
        .EXAMPLE
            Get-ODBCTable -Connection $Connection

            Tables_in_test
            --------------
            bar

            Description
            -----------
            A listing of tables from the database the connection is already attached to
        .EXAMPLE
            Get-ODBCTable -Connection $Connection -Database wordpressdb

            Tables_in_wordpressdb
            ---------------------
            foo
            bar
            sample_tbl

            Description
            -----------
            A listing of tables from the wordpressdb database
        .EXAMPLE
            Get-ODBCTable -Connection $Connection -Database wordpressdb -Table sample_tbl

            Tables_in_wordpressdb
            ---------------------
            sample_tbl

            Description
            -----------
            The sample_tbl from the wordpressdb
        .NOTES
            FunctionName : Get-ODBCTable
            Created by   : rwtaylor
            Date Coded: 12/20/2022 23:33:00
        .LINK
            https://github.com/thecrystalcross/ODBC#Get-ODBCTable
    #>
	[CmdletBinding()]
	Param
	(
		[System.Data.Odbc.OdbcConnection]
		$Connection = $Global:ODBCConnection,
		
		[string]$Database,
		
		[string]$Table
	)
	begin
	{
		try
		{
			$ErrorActionPreference = "Stop";
			if ($Database)
			{
				if (Get-ODBCDatabase -Connection $Connection -Name $Database)
				{
					$Connection.ChangeDatabase($Database);
				}
				else
				{
					throw "Unknown database $($Database)";
				}
			}
			else
			{
				if (!($Connection.Database))
				{
					throw "Please connect to a specific database";
				}
			}
		}
		catch
		{
			$Error[0];
			break
		}
		$db = $Connection.Database;
		if ($Table)
		{
			$Query = "SHOW TABLES FROM $($db) WHERE ``Tables_in_$($db)`` LIKE '$($Table)';"
		}
		else
		{
			$Query = "SHOW TABLES FROM $($db);"
		}
	}
	Process
	{
		try
		{
			Write-Verbose "Invoking SQL";
			Invoke-ODBCQuery -Connection $Connection -Query $Query -ErrorAction Stop;
		}
		catch
		{
			$Error[0];
			break
		}
	}
	End
	{
	}
}