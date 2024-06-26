$global:SOURCE_KeePass = "DominikReichl.KeePass"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function KeePass-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$keepass=winget show --id $global:SOURCE_KeePass
	foreach ($version in $keepass){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de KeePass
    & winget download --id $global:SOURCE_KeePass -d $chemin_dl

	Add-Content $chemin_log 'Telechargement KeePass OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function KeePass-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include "KeePass*.exe" | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de KeePass effectuee"
        $arguments = '/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART'
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel KeePass a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de KeePass"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		KeePass-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		KeePass-Installer $args[1] $args[2]
	}
}
