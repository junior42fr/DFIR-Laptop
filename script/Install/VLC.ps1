$global:SOURCE_VLC = "https://ftp.free.org/mirrors/videolan/vlc/"

function VLC-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement VLC'
    Write-Host "Telechargement VLC (environ 60Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $vlc_niv1 = $(@(Invoke-WebRequest -Uri $global:SOURCE_VLC -UseBasicParsing).links.href) -match '[0-9].[0-9].[0-9]'
    $vlc_niv2 = $global:SOURCE_VLC + $vlc_niv1[-1] + "win64/"
    $vlc_version = $(@(Invoke-WebRequest -Uri $vlc_niv2 -UseBasicParsing).links.href) -match 'msi$'
    $vlc_dl = $vlc_niv2 + $vlc_version
	$version = 'Version :'+$vlc_version
	Add-Content $chemin_log $version
    $vlc_sauvegarde = $chemin_dl + $vlc_version
	
	#Telechargement de VLC
    Invoke-WebRequest -Uri $vlc_dl -UseBasicParsing -OutFile $vlc_sauvegarde

	Add-Content $chemin_log 'Telechargement VLC OK !'
	Add-Content $chemin_log '-----------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function VLC-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include vlc*.msi | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de VLC effectuee"
        $arguments = '/I ' + $logiciel.FullName + ' /quiet'
        Start-Process -Wait msiexec.exe -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel VLC a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de VLC"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		VLC-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		VLC-Installer $args[1] $args[2]
	}
}