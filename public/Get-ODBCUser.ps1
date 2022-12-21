function Get-ODBCUser
{
    <#
        .SYNOPSIS
            Get one or more ODBC Server users
        .DESCRIPTION
            This function will return a list of users from the ODBC server when you omit the User parameter.
        .PARAMETER Connection
            A connection object that represents an open connection to ODBC Server
        .PARAMETER User
            An optional parameter that represents the username of a ODBC Server user
        .EXAMPLE
            Get-ODBCUser -Connection $Connection |Format-Table

            Host        User        Password    Select_priv Insert_priv Update_priv Delete_priv Create_priv Drop_priv   Reload_priv
            ----        ----        --------    ----------- ----------- ----------- ----------- ----------- ---------   -----------
            localhost   root        *A158E86... Y           Y           Y           Y           Y           Y           Y
            127.0.0.1   root        *A158E86... Y           Y           Y           Y           Y           Y           Y
            ::1         root        *A158E86... Y           Y           Y           Y           Y           Y           Y
            localhost   user-01     *2470C0C... N           N           N           N           N           N           N

            Description
            -----------
            This example shows the output when omitting the optional parameter user
        .EXAMPLE
            Get-ODBCUser -Connection $Connection -User user-01


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
            This shows the output when passing in a value for User
        .NOTES
            FunctionName : Get-ODBCUser
            Created by   : rwtaylor
            Date Coded: 12/20/2022 23:33:00
        .LINK
            https://github.com/thecrystalcross/ODBC#Get-ODBCUser
    #>
	[CmdletBinding()]
	Param
	(
		[System.Data.Odbc.OdbcConnection]
		$Connection = $Global:ODBCConnection,
		
		[string]$User
	)
	begin
	{
		if ($User)
		{
			$Query = "SELECT * FROM ODBC.user WHERE ``User`` LIKE '$($User)';";
		}
		else
		{
			$Query = "SELECT * FROM ODBC.user;"
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