function Add-ODBCColumn
{
    <#
        .SYNOPSIS
            Add a column to a ODBC table
        .DESCRIPTION
            This function will add one or more columns to a ODBC table
        .PARAMETER Connection
            A connection object that represents an open connection to ODBC Server
        .PARAMETER Database
            The name of the database to connect ot
        .PARAMETER Table
            The name of the table to add a column to
        .PARAMETER Column
            A hashtable containing at least a name and datatype for a row to be 
            created in the table. For example it could be something as simple or 
            complex as the following
                @{"id"="INT"}
                @{"id"="INT(11) NOT NULL AUTO_INCREMENT";"PRIMARY KEY"="(id)";"Species"="VARCHAR(20)"} 
        .EXAMPLE
            Add-ODBCColumn -Connection $Connection -Database test -Table bar -Column @{"id"="INT(11) NOT NULL AUTO_INCREMENT";"PRIMARY KEY"="(id)";"Species"="VARCHAR(20)"}

            Field   : NAME
            Type    : varchar(20)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : OWNER
            Type    : varchar(20)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : DEATH
            Type    : date
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : BIRTH
            Type    : date
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : id
            Type    : int(11)
            Null    : NO
            Key     : PRI
            Default :
            Extra   : auto_increment

            Field   : Species
            Type    : varchar(20)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Description
            -----------
            This example shows how to add multiple columns to a table
        .NOTES
            FunctionName : Add-ODBCColumn
            Created by   : rwtaylor
            Date Coded: 12/20/2022 23:33:00
        .LINK
            https://github.com/thecrystalcross/ODBC
    #>
	[CmdletBinding()]
	Param
	(
		[System.Data.Odbc.OdbcConnection]
		$Connection = $Global:ODBCConnection,
		
		[string]$Database,
		
		[parameter(Mandatory = $true)]
		[string]$Table,
		
		[parameter(Mandatory = $true)]
		[hashtable]$Column
	)
	begin
	{
		try
		{
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
			$Fields = "";
			foreach ($C in $Column.GetEnumerator()) { $Fields += "$($C.Name) $($C.Value)," };
			$Fields = $Fields.Substring(0, $Fields.Length - 1);
			Write-Verbose $Fields;
			$Query = "ALTER TABLE $($Table) ADD ($($Fields));";
		}
		catch
		{
			$Error[0];
			break
		}
	}
	Process
	{
		try
		{
			Write-Verbose "Invoking SQL";
			Invoke-ODBCQuery -Connection $Connection -Query $Query -ErrorAction Stop;
			Get-ODBCColumn -Connection $Connection -Database $Database -Table $Table;
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