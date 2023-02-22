$global:SOURCE_LibreOffice = "https://download.documentfoundation.org/libreoffice/stable/"

function LibreOffice-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement LibreOffice'
    Write-Host "Telechargement LibreOffice (environ 322Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $libreoffice_niv1 = $(@(Invoke-WebRequest -Uri $global:SOURCE_LibreOffice -UseBasicParsing).links.href) -match '[0-9].[0-9].[0-9]'
    $libreoffice_niv2 = $global:SOURCE_LibreOffice + $libreoffice_niv1[-1] + "win/x86_64/"
    $libreoffice_version = $(@(Invoke-WebRequest -Uri $libreoffice_niv2 -UseBasicParsing).links.href) -match '64.msi$'
    $libreoffice_version = $libreoffice_version[0]
    $libreoffice_dl = $libreoffice_niv2 + $libreoffice_version
	$version = 'Version :'+$libreoffice_version
	Add-Content $chemin_log $version
    $libreoffice_sauvegarde = $chemin_dl + $libreoffice_version

	#Telechargement de LibreOffice
    Invoke-WebRequest -Uri $libreoffice_dl -UseBasicParsing -OutFile $libreoffice_sauvegarde

	Add-Content $chemin_log 'Telechargement LibreOffice OK !'
	Add-Content $chemin_log '-------------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function LibreOffice-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include LibreOffice*.msi | select FullName
    if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de LibreOffice effectuee"
        $arguments = '/I ' + $logiciel.FullName + ' /norestart /qn'
        Start-Process -Wait msiexec.exe -ArgumentList $arguments
    }
	else{
		Write-Host "Aucun logiciel LibreOffice a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de LibreOffice"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		LibreOffice-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		LibreOffice-Installer $args[1] $args[2]
	}
}
