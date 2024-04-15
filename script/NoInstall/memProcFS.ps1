$global:SOURCE_memProcFS = "https://github.com/ufrisk/MemProcFS/releases/download/v5.9/MemProcFS_files_and_binaries_v5.9.6-win_x64-20240408.zip"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function memProcFS-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement memProcFS'
    Write-Host "Telechargement memProcFS" -ForegroundColor DarkBlue -BackgroundColor White
    $memProcFS = $global:SOURCE_memProcFS
    $memProcFS_version = $memProcFS.split("/")[-1]
	$version = 'Version :'+$memProcFS_version
	Add-Content $chemin_log $version
    $memProcFS_sauvegarde = $chemin_dl + $memProcFS_version
	
	#Telechargement de memProcFS
    Invoke-WebRequest -Uri $memProcFS -UseBasicParsing -OutFile $memProcFS_sauvegarde
	
	Add-Content $chemin_log 'Telechargement memProcFS OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		memProcFS-Downloader $args[1] $args[2]
	}
}
