function New-ODBCUser
{
    <#
        .SYNOPSIS
            Create a ODBC User
        .DESCRIPTION
            This function will create a user in the ODBC Server.
        .PARAMETER Connection
            A connection object that represents an open connection to ODBC Server
        .PARAMETER Credential
            A Credential object that represents the user and password to be created on ODBC
        .EXAMPLE
            New-ODBCUser -Connection $Connection -Credential (Get-Credential)

            cmdlet Get-Credential at command pipeline position 1
            Supply values for the following parameters:
            Credential


            Host                   : localhost
            User                   : user-01
            Password               : *2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19
            Select_priv            : N
            Insert_priv            : N
            Update_priv            : N
            Delete_priv            : N
            Create_priv            : N
            Drop_priv              : N
            Reload_priv            : N
            Shutdown_priv          : N
            Process_priv           : N
            File_priv              : N
            Grant_priv             : N
            References_priv        : N
            Index_priv             : N
            Alter_priv             : N
            Show_db_priv           : N
            Super_priv             : N
            Create_tmp_table_priv  : N
            Lock_tables_priv       : N
            Execute_priv           : N
            Repl_slave_priv        : N
            Repl_client_priv       : N
            Create_view_priv       : N
            Show_view_priv         : N
            Create_routine_priv    : N
            Alter_routine_priv     : N
            Create_user_priv       : N
            Event_priv             : N
            Trigger_priv           : N
            Create_tablespace_priv : N
            ssl_type               :
            ssl_cipher             : {}
            x509_issuer            : {}
            x509_subject           : {}
            max_questions          : 0
            max_updates            : 0
            max_connections        : 0
            max_user_connections   : 0
            plugin                 : ODBC_native_password
            authentication_string  :
            password_expired       : N

            Description
            -----------
            This example uses the Get-Credential object to create a user (user-01) on the ODBC Server
        .NOTES
            FunctionName : New-ODBCUser
            Created by   : rwtaylor
            Date Coded: 12/20/2022 23:33:00
        .LINK
            https://github.com/thecrystalcross/ODBC#New-ODBCUser
    #>
	[CmdletBinding()]
	Param
	(
		[System.Data.Odbc.OdbcConnection]
		$Connection = $Global:ODBCConnection,
		
		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]$Credential
	)
	begin
	{
		$Query = "CREATE USER '$($Credential.UserName)'@'$($Connection.DataSource)' IDENTIFIED BY '$($Credential.GetNetworkCredential().Password)';";
	}
	Process
	{
		try
		{
			Write-Verbose "Invoking SQL";
			Invoke-ODBCQuery -Connection $Connection -Query $Query -ErrorAction Stop;
			Write-Verbose "Getting newly created user";
			Get-ODBCUser -Connection $Connection -User $Credential.UserName;
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