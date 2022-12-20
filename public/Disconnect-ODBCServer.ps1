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
            Created by   : jspatton
            Date Coded   : 02/11/2015 12:16:24
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/ODBC#Disconnect-ODBCServer
    #>	
	[OutputType('ODBC.Data.ODBCClient.ODBCConnection')]
	[CmdletBinding()]
	Param
	(
		[Parameter(ValueFromPipeline)]
		[ValidateNotNullOrEmpty()]
		[ODBC.Data.ODBCClient.ODBCConnection]$Connection = $ODBCConnection
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