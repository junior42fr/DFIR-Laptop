$global:SOURCE_VirtualBoxExtPack = "https://www.virtualbox.org/wiki/Downloads"
$global:VIRTUALBOX = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

function VirtualBoxExtPack-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement VirtualBoxExtPack'
    Write-Host "Telechargement VirtualBox Extension Pack (environ 20Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $virtualbox_extpack = $(@(Invoke-WebRequest -Uri $global:SOURCE_VirtualBoxExtPack -UseBasicParsing).links.href) -match "extpack"
    $virtualbox_extpack_dl = $virtualbox_extpack[0]
    $virtualbox_extpack_version = $virtualbox_extpack.split("/")[-1]
	Add-Content $chemin_log $version
    $virtualbox_extpack_sauvegarde = $chemin_dl + $virtualbox_extpack_version

    #Telechargement de VirtualBoxExtPack
    Invoke-WebRequest -Uri $virtualbox_extpack_dl -UseBasicParsing -Outfile $virtualbox_extpack_sauvegarde

	Add-Content $chemin_log 'Telechargement VirtualBoxExtPack OK !'
	Add-Content $chemin_log '---------------------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function VirtualBoxExtPack-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Oracle*.vbox-extpack | select FullName
	if(($logiciel.FullName) -AND (Get-WmiObject -Class Win32_Product |where name -match "VirtualBox")){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de VirtualBoxExtPack effectuee"
        echo y | & $global:VIRTUALBOX extpack install --replace $logiciel.FullName
	}
	else{
		Write-Host "Aucun logiciel VirtualBoxExtPack a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Aucun logiciel VirtualBoxExtPack a installer"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		VirtualBoxExtPack-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		VirtualBoxExtPack-Installer $args[1] $args[2]
	}
}