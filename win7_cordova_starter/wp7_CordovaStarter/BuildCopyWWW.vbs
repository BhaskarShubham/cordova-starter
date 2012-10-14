'
'Usage
'WScript BuildCopyWWW.vbs <sourceDir> <destinationDir>
'sourceDir     : the directory wich will be copied recursive to destination directory
'destinationDir: optional, the directory in wich the source directory will be copyied to
'                if destination directory is not set then script uses $Project/www as destination
'
On Error Resume Next

args = WScript.Arguments.Count
 
If args < 1 Then
   WScript.Echo "usage: args.vbs argument [argument] [argument] "
   WScript.Quit
 End If

wwwsources=""

Dim arrFolders()
intSize = 0

strComputer = "."

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

strProjectDir = WScript.Arguments.Item(0)
strDestFolder = strProjectDir & "www"

Set objFSO = CreateObject("Scripting.FileSystemObject")
strSrcFolderName = objFSO.GetFolder(strProjectDir).ParentFolder.ParentFolder.Path & "\www\www"

If args > 1 Then
strArg1=WScript.Arguments.Item(1)
If Not strArg1=Nothing And Not LTrim(RTrim(strArg1))="" Then
If Not Left(strArg1, Len(strProjectDir)) = strProjectDir Then
strArg1 = strProjectDir & strArg1
End If

strOutputDir=strArg1
If Not Right(strOutputDir, Len("www")) = "www" Then
strOutputDir= strOutputDir & "www"
End If
strDestFolder = strOutputDir
End If
End If
'Wscript.Echo "strProjectDir: " & strProjectDir & " - strSrcFolderName: " & strSrcFolderName & " - strDestFolder: " & strDestFolder 

GetSubFolders strSrcFolderName 

Sub GetSubFolders(strFolderPath)
    Set colSubfolders = objWMIService.ExecQuery _
        ("Associators of {Win32_Directory.Name='" & strFolderPath & "'} " _
            & "Where AssocClass = Win32_Subdirectory " _
                & "ResultRole = PartComponent")

    For Each objFolder in colSubfolders
        strSubFolderName = lcase(objFolder.Name)
        ReDim Preserve arrFolders(intSize)
        arrFolders(intSize) = strSubFolderName
        intSize = intSize + 1
        GetSubFolders strSubFolderName
    Next
End Sub


Set filesys = CreateObject("Scripting.FileSystemObject")
If filesys.FolderExists(strDestFolder) Then  
   filesys.DeleteFolder strDestFolder
End If 

Set objFSODest = CreateObject("Scripting.FileSystemObject")
objFSODest.CreateFolder(strDestFolder)


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'files in root folder
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFolder = objFSO.GetFolder(strSrcFolderName) 
Set colFiles = objFolder.Files
For Each objFile in Colfiles
If Not lcase(Left(objFile.Name,1)) = "." Then
strTar=strDestFolder & "/" & objFile.Name
objFSO.CopyFile objFile,(strTar)
wwwsources = wwwsources & ";" & strTar
End If
Next

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'recurse folder content
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Set objFSO = CreateObject("Scripting.FileSystemObject")
For Each strFolder in arrFolders
    strFolderName = lcase(strFolder) 
	strFolderName = Replace(strFolderName,"/","\")
	
    strDestinationF = lcase(strDestFolder)
    strSourceF = Replace(strSrcFolderName,"/","\")
	
instring = InStr(strFolderName, lcase(strSourceF)) + Len(strSourceF)
xrlen = Len(strFolderName) - instring
xinstring = Right(strFolderName, xrlen+1)
strNewFolder = strDestinationF & xinstring
Set objNewFolder = objFSO.CreateFolder(strNewFolder)

Set objFSOorg = CreateObject("Scripting.FileSystemObject")
Set objFolderorg = objFSOorg.GetFolder(strFolder) 
Set colFiles = objFolderorg.Files
For Each objFile in colfiles
If Not lcase(Left(objFile.Name,1)) = "." Then
strTar=strNewFolder & "/" & objFile.Name
''''''''''''''''''''''''''''''''''''''
'exclude ipad, iphone, blackberry and android images
''''''''''''''''''''''''''''''''''''''
If 0 = InStr(lcase(strTar),lcase("ipad_")) _
And 0 = InStr(lcase(strTar),lcase("iphone_")) _
And 0 = InStr(lcase(strTar),lcase("android_")) _
And 0 = InStr(lcase(strTar),lcase("blackberry_")) _
Then

objFSO.CopyFile objFile,(strTar)
wwwsources = wwwsources & ";" & strTar
End If
End If
Next
Next



''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'copy .JS resources of directory Plugin into root directory (www)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
strSrcFolderName_P=strProjectDir & "Plugins"
strDestFolder_P=strOutputDir
'Wscript.Echo strSrcFolderName_P & "-" & strDestFolder_P
Set objFSO_P = CreateObject("Scripting.FileSystemObject")
Set objFolder_P = objFSO_P.GetFolder(strSrcFolderName_P) 
Set colFiles_P = objFolder_P.Files
For Each objFile_P in Colfiles_P
If lcase(Right(objFile_P.Name,3)) = ".js" Then
strTar_P=strDestFolder_P & "/" & objFile_P.Name
objFSO_P.CopyFile objFile_P,(strTar_P)
wwwsources = wwwsources & ";" & strTar_P
End If
Next

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Add HTML resources (no folders) to CordovaSourceDictionary.xml
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Const ForWriting = 2 
Set fsoCSD = CreateObject("Scripting.FileSystemObject")
Set outFileCSD = fsoCSD.OpenTextFile(strProjectDir & "\CordovaSourceDictionary.xml", ForWriting, true)

outFileCSD.WriteLine("<?xml version=""1.0"" encoding=""utf-8""?>")
outFileCSD.WriteLine("<!-- This file is auto-generated, do not edit! -jm daniele -->")
outFileCSD.WriteLine("<CordovaSourceDictionary>")

splitted= Split(wwwsources,";")
For Each strF in splitted
'from and incl. www
finstring = InStr(strF, lcase("www"))
fxrlen = Len(strF) - finstring
fxinstring = Right(strF, fxrlen+1)
'the only valid path separator is Backspace
fstrIndexPath = Replace(fxinstring,"/","\")
IF Len(RTrim(LTrim(fstrIndexPath))) > 0 Then
outFileCSD.WriteLine("    <FilePath Value=""" & fstrIndexPath & """/>")
End IF
Next
outFileCSD.WriteLine("</CordovaSourceDictionary>")
outFileCSD.Close