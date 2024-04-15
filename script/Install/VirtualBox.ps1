$global:SOURCE_VirtualBox = "Oracle.VirtualBox"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function VirtualBox-Downloader([string]$chemin_dl,[string]$chemin_log){
 	#Récupération de la version et inscription dans le fichier de log
	$virtualbox=winget show --id $global:SOURCE_VirtualBox
	foreach ($version in $virtualbox){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de VirtualBox
    & winget download --id $global:SOURCE_VirtualBox -d $chemin_dl --skip-dependencies
		
    Add-Content $chemin_log 'Telechargement VirtualBox OK !'
	Add-Content $chemin_log '------------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function VirtualBox-Installer([string]$chemin_dl,[string]$chemin_log){
   	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include *VirtualBox*.exe | select FullName
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
