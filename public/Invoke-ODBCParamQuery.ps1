function Invoke-ODBCParamQuery
{
    <#
        .SYNOPSIS
            Run a parameterized ad-hoc query against a ODBC Server
        .DESCRIPTION
            This function can be used to run parameterized ad-hoc queries against a ODBC Server. 
        .PARAMETER Connection
            A connection object that represents an open connection to ODBC Server
        .PARAMETER Query
            A valid ODBC query
        .PARAMETER Parameters
            An array of parameters
        .PARAMETER Values
            An array of values for the parameters
        .EXAMPLE
            Invoke-ODBCParamQuery -Connection $Connection -Query "INSERT INTO foo (Animal, Name) VALUES (@animal, @name);" -Parameters "@animal","@name" -Values "Bird","Poll"

            Description
            -----------
            Add data to a sql table
        .NOTES
            FunctionName : Invoke-ODBCParamQuery
            Created by   : ThatAstronautGuy
            Date Coded   : 25/07/2018
    #>
    [CmdletBinding()]
	Param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Query,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[ODBC.Data.ODBCClient.ODBCConnection]$Connection = $ODBCConnection,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Parameters,

        [Parameter(Mandatory)]
        $Values
	)
	begin
	{
		$ErrorActionPreference = 'Stop'
	}
	Process
	{
		try

		{
			
			[ODBC.Data.ODBCClient.ODBCCommand]$command = New-Object ODBC.Data.ODBCClient.ODBCCommand
            $command.Connection = $Connection
			$command.CommandText = $Query
            $cc=($parameters | Measure-Object).Count
            $i=0
            $parameters | ForEach-Object {
                if ($cc -eq 1)
                {
                    $vv=$values
                    $ff=$parameters
                }
                else
                {
                    $vv=$values[$i]
                    $ff=$parameters[$i]
                }
                Switch ($vv.GetType())
                {
                    System.IO.MemoryStream {
                        $stream=[System.IO.MemoryStream]$vv
                        $stream.Position=0
                        $ary=$stream.ToArray()
                        $p=[ODBC.Data.ODBCClient.ODBCParameter]::new()
                        $p.ParameterName=$ff
                        $p.DbType='Object'
                        $p.Value=[byte[]]$ary
                        $tmp = $command.Parameters.Add($p)
                    }
                    default {
                        $v=[string]$vv
                        $tmp = $command.Parameters.AddWithValue($ff, $v)
                    }
                }
                $i+=1                
            }
			[ODBC.Data.ODBCClient.ODBCDataAdapter]$dataAdapter = New-Object ODBC.Data.ODBCClient.ODBCDataAdapter($command)
			$dataSet = New-Object System.Data.DataSet
			$recordCount = $dataAdapter.Fill($dataSet)
			Write-Verbose "$($recordCount) records found"
			$dataSet.Tables.foreach{$_}
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}