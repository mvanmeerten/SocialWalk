call taskkill /f /im java.exe
IF %1%==-r (call webdsl reindex)
IF %1%==-c (call webdsl clean)
call webdsl run
