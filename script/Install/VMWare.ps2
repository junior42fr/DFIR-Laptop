$global:SOURCE_VMWare = "VMware.WorkstationPro"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function VMWare-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$vmware=winget show --id $global:SOURCE_VMWare
	foreach ($version in $vmware){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de VMWare
    & winget download --id $global:SOURCE_VMWare -d $chemin_dl --accept-package-agreements --skip-dependencies

	Add-Content $chemin_log 'Telechargement VMWare OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function VMWare-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include VMware*.exe | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de VMWare Workstation Pro effectuee"
        $arguments = '/s /v/qn EULAS_AGREED=1 AUTOSOFTWAREUPDATE=0 DATACOLLECTION=0 ADDLOCAL=ALL
      REBOOT=ReallySuppress'
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel VMWare a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de VMWare"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		VMWare-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		VMWare-Installer $args[1] $args[2]
	}
}
