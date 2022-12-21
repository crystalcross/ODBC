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
            Created by   : rwtaylor
            Date Coded: 12/20/2022 23:33:00
    #>
    [CmdletBinding()]
	Param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Query,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[System.Data.Odbc.OdbcConnection]$Connection = $ODBCConnection,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Parameters,

        [Parameter(Mandatory)]
        $Values
	)
	begin
	{
        $pc=($Parameters | Measure-Object).Count
        $pv=($Values | Measure-Object).Count
        if ($pc -ne $pv)
        {
            Write-Error "Invalid Parameter Count - $pc Parameters but only $pv values."
            return
        }
	}
	Process
	{
		[System.Data.Odbc.OdbcCommand]$command = New-Object System.Data.Odbc.OdbcCommand
        $command.Connection = $Connection
		try
		{
            $qry=$Query
            if ($pc -gt 0)
            {
                # We have parameters - first we must put them into an array because ODBC doesn't
                # like named parameters and we must jump through hoops to make this crap work!
                #
                $pars=@{}
                if ($pc -eq 1) { $Parameters=@(,$Parameters) }
                if ($pv -eq 1) { $Values=@(,$Values) }
                $i=0
                $Parameters | ForEach-Object {
                    $vv=$values[$i]
                    $ff=$parameters[$i]
                    Switch ($vv.GetType())
                    {
                        System.IO.MemoryStream {
                            $stream=[System.IO.MemoryStream]$vv
                            $stream.Position=0
                            $ary=$stream.ToArray()
                            $p=[System.Data.Odbc.OdbcParameter]::new()
#                            $p.ParameterName=$ff
                            $p.OdbcType=[System.Data.Odbc.OdbcType]::Binary
                            $p.DbType=[System.Data.DbType]::Object
                            $p.Value=[byte[]]$ary
                            $pars[$ff]=$p
                        }
                        default {
                            $v=[string]$vv
                            $p=[System.Data.Odbc.OdbcParameter]::new()
 #                           $p.ParameterName=$ff
                            $p.OdbcType=[System.Data.Odbc.OdbcType]::NVarChar
                            $p.DbType=[System.Data.DbType]::String
                            $p.Value=$v
                            $pars[$ff]=$p
                            #$tmp = $command.Parameters.Add($p)
                        }
                    }
                    $i+=1
                }
                # Now that we have a list of all parameters referenced by name, lets
                # swap them out in the Query and then put them into order in the command.
                # Keeping in mind that some may be referenced more than once!
                # Isn't this fun?   Just because ODBC doesn't like named parameters.  
                # (And yes, the author is not amused)
                #
                $rsafe=$Parameters | ForEach-Object { [Regex]::Escape($_) }
                $rsafe=$rsafe -join('|')
                # Now we have them in the form of a Select-String pattern.  Impressed yet?
                # (Ok, me neither)
                #
                $mch=$qry | Select-String -Pattern $rsafe -AllMatches
                if ($mch -ne $null)
                {
                    #Now after all that, yes they are actually referenced in the Query
                    #(imagine that!)
                    #
                    $pname=@()
                    $mch=$mch.Matches
                    $mch=$mch | Sort-Object -Property Index -Descending
                    # First we had to get a list of where the parameter names are referenced
                    # Then we put them in order from farthest right to left.   Why?  Because we
                    # are now about to replace them, and if we go from left to right the index 
                    # changes as we replace them.   Nifty, eh?
                    #
                    ForEach ($pmatch in $mch)
                    {
                        $qry=$qry.remove($pmatch.Index,$pmatch.Length).insert($pmatch.Index,'?')
                        $pname+=@(,$pmatch.Value)
                    }
                    # Now since we went from right to left, and we need to reference the parameters
                    # in the SQL Query from left to right, lets reverse them again.
                    [array]::Reverse($pname)
                    # And finally now lets add these parameters to the command in the right order.
                    $pname | ForEach-Object {
                        if ($pars[$_])
                        {
                            $tmp=$command.Parameters.Add($pars[$_].Clone())
                        }
                    }
                }
            }
            $command.CommandText = $qry
            [System.Data.Odbc.OdbcDataAdapter]$dataAdapter = New-Object System.Data.Odbc.OdbcDataAdapter($command)
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