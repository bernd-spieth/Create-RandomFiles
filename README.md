
# New-RandomFilesInFolders

Creates random files with or without a folder structure. The script is based on the script from Stéphane van Gulick that creates random files. I added a function to also create a folder structure and place the random files there.

You can start the function that creates the files and folders with the following call:

`
New-RandomFilesInFolders -TotalSize 100MB -NumberOfFiles 100 -Path "C:\Temp" -FilesType "Office" -MaxFolderDepth 5 -MaxFolderCount 30
`

If the MaxFolderCount parameter is not specified then the script will create only the files and no folders.
