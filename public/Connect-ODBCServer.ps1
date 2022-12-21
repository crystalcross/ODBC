function Connect-ODBCServer
{
	<#
	.SYNOPSIS
		Connect to a ODBC Server
	.DESCRIPTION
		This function will establish a connection to a local or remote instance of 
		a ODBC Server. By default it will connect to the local instance on the 
		default port.
	.PARAMETER Driver
		The name of the ODBC Driver to use for the connection, the default is MariaDB.
	.PARAMETER ComputerName
		The name of the remote computer to connect to, otherwise default to localhost
	.PARAMETER Port
		By default this is 3306, otherwise specify the correct value
	.PARAMETER Credential
		Typically this may be your root credentials, or to work in a specific 
		database the credentials with appropriate rights to do work in that database.
	.PARAMETER Database
		An optional parameter that will connect you to a specific database
	.PARAMETER CommandTimeOut
		By default command timeout is set to 30, otherwise specify the correct value
	.PARAMETER ConnectionTimeOut
		By default connection timeout is set to 15, otherwise specify the correct value
	.EXAMPLE
		Connect-ODBCServer -Credential (Get-Credential)

		cmdlet Get-Credential at command pipeline position 1
		Supply values for the following parameters:
		Credential


		ServerThread      : 2
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

		Description
		-----------
		Connect to the local ODBC instance as root. This example uses the 
		Get-Credential cmdlet to prompt for username and password.
	.EXAMPLE
		Connect-ODBCServer -ComputerName db.company.com -Credential (Get-Credential)

		cmdlet Get-Credential at command pipeline position 1
		Supply values for the following parameters:
		Credential


		ServerThread      : 2
		DataSource        : db.company.com
		ConnectionTimeout : 15
		Database          :
		UseCompression    : False
		State             : Open
		ServerVersion     : 5.6.22-log
        Driver            : MariaDB ODBC 3.1 Driver
		ConnectionString  : server=db.company.com;port=3306;User Id=root
		IsPasswordExpired : False
		Site              :
		Container         :

		Description
		-----------
		Connect to a remote ODBC instance as root. This example uses the 
		Get-Credential cmdlet to prompt for username and password.
	.EXAMPLE
		Connect-ODBCServer -Credential (Get-Credential) -CommandTimeOut 60 -ConnectionTimeOut 25

		cmdlet Get-Credential at command pipeline position 1
		Supply values for the following parameters:
		Credential


		ServerThread      : 2
        Driver            : MariaDB ODBC 3.1 Driver
		DataSource        : localhost
		ConnectionTimeout : 25
		Database          :
		UseCompression    : False
		State             : Open
		ServerVersion     : 5.6.22-log
		ConnectionString  : server=localhost;port=3306;User Id=root;defaultcommandtimeout=60;connectiontimeout=25
		IsPasswordExpired : False
		Site              :
		Container         :

		Description
		-----------
		This example set the Command Timout to 60 and the Connection Timeout to 25. Both are optional when calling the Connect-ODBCServer function.
	.NOTES
		FunctionName : Connect-ODBCServer
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
		[pscredential]$Credential,

		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Driver = 'MariaDB',
				
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$ComputerName = $env:COMPUTERNAME,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$Port = 3306,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Database,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$CommandTimeOut = 30,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$ConnectionTimeOut = 15
	)
	begin
	{
        $drv=Get-OdbcDriver -Name "*$($Driver)*"
        if ($drv)
        {
		    if ($PSBoundParameters.ContainsKey('Database')) {
			    $connectionString = 'DRIVER={{{0}}};Server={1};PORT={2};UID={3};PASSWORD={4};DATABASE={5};' -f $drv.Name,$ComputerName,$Port,$Credential.UserName, $Credential.GetNetworkCredential().Password,$Database
		    }
		    else
		    {
			    $connectionString = 'DRIVER={{{0}}};Server={1};PORT={2};UID={3};PASSWORD={4};' -f $drv.Name,$ComputerName,$Port,$Credential.UserName, $Credential.GetNetworkCredential().Password
		    }
		    $connectionString = $connectionString + "default command timeout=$CommandTimeOut; Connection Timeout=$ConnectionTimeOut;Allow User Variables=True"
        }
        else
        {
            Write-Verbose "Invalid Driver type '$Driver'."
            return
        }
	}
	process
	{
		try
		{
			[System.Data.Odbc.OdbcConnection]$conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
            $conn.Open();
        }
        catch {
        	Write-Error -Message $_.Exception.Message
            return
        }
        try {
			$Global:ODBCConnection = $conn
			if ($PSBoundParameters.ContainsKey('Database')) {
				$null =  New-Object System.Data.Odbc.OdbcCommand("USE $Database", $conn)
			}
			$conn
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}