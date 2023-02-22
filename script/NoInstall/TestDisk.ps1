$global:SOURCE_TestDisk = "https://www.cgsecurity.org/wiki/TestDisk_Download"

function TestDisk-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement TestDisk'
    Write-Host "Telechargement TestDisk/Photorec pour Windows (environ 25Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $testdisk = Invoke-WebRequest -Uri $global:SOURCE_TestDisk -UseBasicParsing
    $testdisk = @($testdisk.links.href |Select-String "win64.zip" |sort -Unique -Descending)[0]
    $testdisk_dl = $testdisk.Line -replace "Download_and_donate.php/"
    #Parametrage du nom de fichier local telecharge
    $testdisk_version = $testdisk_dl.split("/")[-1]
    $testdisk_sauvegarde = $chemin_dl + $testdisk_version
	$version = 'Version :'+$testdisk_version
	Add-Content $chemin_log $version
 
	#Telechargement de TestDisk
    Invoke-WebRequest -Uri $testdisk_dl -UseBasicParsing -Outfile $testdisk_sauvegarde

	Add-Content $chemin_log 'Telechargement TestDisk OK !'
	Add-Content $chemin_log '----------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		TestDisk-Downloader $args[1] $args[2]
	}
}
