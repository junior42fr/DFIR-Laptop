$global:SOURCE_VC = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$global:SOURCE_VirtualBox = "https://www.virtualbox.org/wiki/Downloads"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function VirtualBox-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
    Add-Content $chemin_log 'Telechargement Microsoft Visual C++ Redistributable'
    Write-Host "Telechargement Microsoft Visual C++ Redistributable (environ 25Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $vc_version = $global:SOURCE_VC.split("/")[-1]
    $vc_sauvegarde = $chemin_dl + $vc_version

    #Telechargement de Microsoft Visual C++ Redistributable
    Invoke-WebRequest -Uri $global:SOURCE_VC -UseBasicParsing -OutFile $vc_sauvegarde

    Add-Content $chemin_log 'Telechargement VirtualBox'
    Write-Host "Téléchargement VirtualBox (environ 103Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $virtualbox = $(@(Invoke-WebRequest -Uri $global:SOURCE_VirtualBox -UseBasicParsing).links.href) -match 'exe$'
    $virtualbox_dl = $virtualbox[0]
    $virtualbox_version = $virtualbox.split("/")[-1]
	$version = 'Version :'+$virtualbox_version
	Add-Content $chemin_log $version
    $virtualbox_sauvegarde = $chemin_dl + $virtualbox_version

    #Telechargement de VirtualBox
    Invoke-WebRequest -Uri $virtualbox_dl -UseBasicParsing -Outfile $virtualbox_sauvegarde

    Add-Content $chemin_log 'Telechargement VirtualBox OK !'
	Add-Content $chemin_log '------------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function VirtualBox-Installer([string]$chemin_dl,[string]$chemin_log){
   	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include VC*.exe | select FullName
	if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de  Microsoft Visual C++ Redistributable effectuee"
		& $logiciel.FullName /Q /norestart
    }
    else{
        Write-Host "Aucun logiciel Microsoft Visual C++ Redistributable a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Aucun logiciel Microsoft Visual C++ Redistributable a installer"
    }
	Add-Content $chemin_log '-------------------------'

    #Attente de la fin de l'installation de Microsoft Visual C++ Redistributable
    sleep 10

   	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include VirtualBox*.exe | select FullName
	if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        $arguments = "--silent --ignore-reboot"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
        $env:Path += ";C:\Program Files\Oracle\VirtualBox"
        Add-Content $chemin_log "Installation de VirtualBox effectuee"
    }
    else{
        Write-Host "Aucun logiciel VirtualBox a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Aucun logiciel VirtualBox a installer"
    }
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		VirtualBox-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		VirtualBox-Installer $args[1] $args[2]
	}
}
