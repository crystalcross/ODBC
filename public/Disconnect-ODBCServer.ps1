function Disconnect-ODBCServer
{
    <#
        .SYNOPSIS
            Disconnect a ODBC connection
        .DESCRIPTION
            This function will disconnect (logoff) a ODBC server connection
        .PARAMETER Connection
            A connection object that represents an open connection to ODBC Server
        .EXAMPLE
            $Connection = Connect-ODBCServer -Credential (Get-Credential)
            Disconnect-ODBCServer -Connection $Connection


            ServerThread      :
            DataSource        : localhost
            ConnectionTimeout : 15
            Database          :
            UseCompression    : False
            State             : Closed
            ServerVersion     :
            ConnectionString  : server=localhost;port=3306;User Id=root
            IsPasswordExpired :
            Site              :
            Container         :

            Description
            -----------
            This example shows connecting to the local instance of ODBC 
            Server and then disconnecting from it.
        .NOTES
            FunctionName : Disconnect-ODBCServer
            Created by   : rwtaylor
            Date Coded: 12/20/2022 23:33:00
        .LINK
            https://github.com/thecrystalcross/ODBC
    #>	
	[OutputType('System.Data.Odbc.OdbcConnection')]
	[CmdletBinding()]
	Param
	(
		[Parameter(ValueFromPipeline)]
		[ValidateNotNullOrEmpty()]
		[System.Data.Odbc.OdbcConnection]$Connection = $ODBCConnection
	)
	process
	{
		try {
			$Connection.Close()
			$Connection
		}
		catch 
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}