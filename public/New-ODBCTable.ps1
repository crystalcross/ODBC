function New-ODBCTable
{
    <#
        .SYNOPSIS
            Create a table 
        .DESCRIPTION
            This function creates a table
        .PARAMETER Connection
            A connection object that represents an open connection to ODBC Server
        .PARAMETER Table
            The name of the table to create
        .PARAMETER Database
            The name of the database to create the table in, if blank the current database
        .PARAMETER Column
            A hashtable containing at least a name and datatype for a row to be 
            created in the table. For example it could be something as simple or 
            complex as the following
                @{"id"="INT"}
                @{"id"="INT(11) NOT NULL AUTO_INCREMENT","PRIMARY KEY"="(id)"} 
        .EXAMPLE
            $Fields.GetEnumerator()

            Name                           Value
            ----                           -----
            Death                          DATE
            Birth                          DATE
            Owner                          VARCHAR (20)
            Species                        VARCHAR (20)
            Sex                            VARCHAR (1)
            Name                           VARCHAR (20)

            New-ODBCTable -Connection $Connection -Table bar -Column $Fields

            Tables_in_wordpressdb
            ---------------------
            bar

            Description
            -----------
            This example shows using a hashtable object to set the field names 
            and values of the various fields to be created in the new table. It 
            then shows how to create a table with that object.
        .EXAMPLE
            New-ODBCTable -Connection $Connection -Table sample_tbl -Column @{"id"="INT(11) NOT NULL AUTO_INCREMENT";"PRIMARY KEY"="(id)"}


            Tables_in_wordpressdb
            ---------------------
            sample_tbl

            Description
            -----------
            This example shows creating a table and passing in the column defintions on the command line
        .NOTES
            FunctionName : New-ODBCTable
            Created by   : rwtaylor
            Date Coded: 12/20/2022 23:33:00
        .LINK
            https://github.com/thecrystalcross/ODBC#New-ODBCTable
    #>
	[CmdletBinding()]
	Param
	(
		[System.Data.Odbc.OdbcConnection]
		$Connection = $Global:ODBCConnection,
		
		[parameter(Mandatory = $true)]
		[string]$Table,
		
		[string]$Database,
		
		[parameter(Mandatory = $true)]
		[hashtable]$Column
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
		$Fields = "";
		foreach ($C in $Column.GetEnumerator()) { $Fields += "$($C.Name) $($C.Value)," };
		$Fields = $Fields.Substring(0, $Fields.Length - 1);
		Write-Verbose $Fields;
		$Query = "CREATE TABLE $($Table) ($($Fields));"
	}
	Process
	{
		try
		{
			Write-Verbose "Invoking SQL";
			Invoke-ODBCQuery -Connection $Connection -Query $Query -ErrorAction Stop;
			Write-Verbose "Getting newly created table";
			Get-ODBCTable -Connection $Connection -Table $Table;
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