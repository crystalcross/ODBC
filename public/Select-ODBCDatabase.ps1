function Select-ODBCDatabase
{
    <#
        .SYNOPSIS
            Set the default database to work with
        .DESCRIPTION
            This function sets the default database to use, this value is 
            pulled from the connection object on functions that have database 
            as a parameter.
        .PARAMETER Connection
        .PARAMETER Database
        .EXAMPLE
            # rwtaylor@IT08082 | 16:35:02 | 02-16-2015 | C:\projects\mod-posh\powershell\production $
            Connect-ODBCServer -Credential (Get-Credential)

            cmdlet Get-Credential at command pipeline position 1
            Supply values for the following parameters:
            Credential


            ServerThread      : 12
            DataSource        : localhost
            ConnectionTimeout : 15
            Database          :
            UseCompression    : False
            State             : Open
            ServerVersion     : 5.6.22-log
            ConnectionString  : server=localhost;port=3306;User Id=root
            IsPasswordExpired : False
            Site              :
            Container         :



            Get-ODBCDatabase

            Database
            --------
            information_schema
            mynewdb
            ODBC
            mytest
            performance_schema
            test
            testing
            wordpressdb
            wordpressdb1
            wordpressdb2


            Select-ODBCDatabase -Database mytest


            ServerThread      : 12
            DataSource        : localhost
            ConnectionTimeout : 15
            Database          : mytest
            UseCompression    : False
            State             : Open
            ServerVersion     : 5.6.22-log
            ConnectionString  : server=localhost;port=3306;User Id=root
            IsPasswordExpired : False
            Site              :
            Container         :

            Description
            -----------
            This example shows connecting to ODBC Server, you can see there is no value for database. 
            Then we list all the databases on the server, and finally we select the mytest database. 
            The output of the command shows that we are now using mytest.
        .NOTES
            FunctionName : Select-ODBCDatabase
            Created by   : rwtaylor
            Date Coded: 12/20/2022 23:33:00
        .LINK
            https://github.com/thecrystalcross/ODBC
#>	
	[OutputType('System.Data.Odbc.OdbcConnection')]
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Database,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[System.Data.Odbc.OdbcConnection]$Connection = $ODBCConnection
	)
	process
	{
		try
		{
			if (-not (Get-ODBCDatabase -Connection $Connection -Name $Database))
			{
				throw "Unknown database $($Database)"
			}
			else
			{
				$Connection.ChangeDatabase($Database)
			}
			$Global:ODBCConnection = $Connection
			$Connection
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}
