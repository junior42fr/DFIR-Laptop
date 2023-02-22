$global:SOURCE_WindowsDefender = "https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64"

function WinDefender-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Windows Defender'
    Write-Host "Telechargement de la mise a jour de Windows Defender" -foregroundcolor DarkBlue -backgroundcolor White
    $date_export = Get-Date -Format "yyyy-MM-dd"
	$defender_version = "Windows-defender-update_"+$date_export+".exe"
    $defender_sauvegarde = $chemin_dl + $defender_version
	$version = 'Version :'+$defender_version
	Add-Content $chemin_log $version
 
	#Telechargement de Windows Defender
    Invoke-WebRequest -Uri $global:SOURCE_WindowsDefender -OutFile $defender_sauvegarde

	Add-Content $chemin_log 'Telechargement Windows Defender OK !'
	Add-Content $chemin_log '------------------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function WinDefender-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Windows-defender*.exe | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de WinDefender effectuee"
        Start-Process -Wait $logiciel.Fullname
	}
	else{
		Write-Host "Aucun logiciel WinDefender a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de WinDefender"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		WinDefender-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		WinDefender-Installer $args[1] $args[2]
	}
}