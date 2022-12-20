function Get-ODBCDatabase
{
    <#
        .SYNOPSIS
            Get one or more tables from a ODBC Server
        .DESCRIPTION
            This function returns one or more Database names from a ODBC Server
        .PARAMETER Connection
            A connection object that represents an open connection to ODBC Server
        .PARAMETER Name
            An optional parameter that if provided will scope the output to the requested 
            DB. If blank this will return all the Datbases the user has the ability to 
            see based on their credentials.
        .EXAMPLE
            Get-ODBCDatabase -Connection $Connection

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
            This example shows the output when the Name parameter is ommitted.
        .EXAMPLE
            Get-ODBCDatabase -Connection $Connection -Name mynewdb

            Database
            --------
            mynewdb

            Description
            -----------
            This example shows the output when passing in the name of a Database.
        .NOTES
            FunctionName : Get-ODBCDatabase
            Created by   : jspatton
            Date Coded   : 02/11/2015 10:05:20
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/ODBC#Get-ODBCDatabase
    #>
	[CmdletBinding()]
	Param
	(
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[ODBC.Data.ODBCClient.ODBCConnection]$Connection = $ODBCConnection,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Name
	)
	process
	{
		try
		{
			if ($PSBoundParameters.ContainsKey('Name'))
			{
				$query = "SHOW DATABASES WHERE ``Database`` LIKE '$($Name)';"
			}
			else
			{
				$query = 'SHOW DATABASES;'
			}
			Invoke-ODBCQuery -Connection $Connection -Query $query -ErrorAction Stop
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}