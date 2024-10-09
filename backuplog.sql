-------------
-- backup db
-------------
SET NOCOUNT ON;
declare @name varchar(250);
declare @path varchar(250);
declare @extname varchar(20)
set @extname =  '_'+convert(varchar(5),DATENAME(wk, getdate()) % 2) 

declare @sqlcommand varchar(500);

set @path = 'e:\backup\'

declare dblist cursor
for select name   from sys.databases where DB_ID(name) = 1 or DB_ID(name) > 4
for read only

open dblist
FETCH NEXT from dblist into @name
WHILE @@FETCH_STATUS = 0 BEGIN
	set @sqlcommand = 'backup database '+@name+' to disk = '''+@path + @name+@extname +'.bak'' with init'
	-- PRINT @sqlcommand
	EXEC(@sqlcommand)
	FETCH NEXT from dblist into @name
END
CLOSE dblist
DEALLOCATE dblist
-------------
-- Backup log
-------------
SET NOCOUNT ON;
declare @name varchar(250);
declare @path varchar(250);
declare @extname varchar(20)
declare @errormessage varchar(350)
set @extname =  DATENAME(WEEKDAY, getdate())+'_'

declare @sqlcommand varchar(500);

set @path = 'e:\backup\'

declare dblist cursor
for select name   from sys.databases where DB_ID(name) > 4
for read only

open dblist
FETCH NEXT from dblist into @name
WHILE @@FETCH_STATUS = 0 BEGIN
	begin try
		set @sqlcommand = 'backup log '+@name+' to disk = '''+@path +'log'+ @extname+@name +'.lbak'' with init'
		--PRINT @sqlcommand
		EXEC(@sqlcommand)
	end try
	begin catch
		set @errormessage = 'Error backup : '+@sqlcommand
		raiserror (@errormessage,16,1)
	end catch
	FETCH NEXT from dblist into @name
END
CLOSE dblist
DEALLOCATE dblist
