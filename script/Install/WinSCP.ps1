$global:SOURCE_Winscp = "WinSCP.WinSCP"

function Winscp-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$winscp=winget show --id $global:SOURCE_Winscp
	foreach ($version in $winscp){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de 7-zip
    & winget download --id $global:SOURCE_Winscp -d $chemin_dl
	Add-Content $chemin_log 'Telechargement WinSCP OK !'
	Add-Content $chemin_log '--------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Winscp-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Winscp*.exe | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Winscp effectuee"
        $arguments = "/silent /allusers /norestart"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
 	}
	else{
		Write-Host "Aucun logiciel WinSCP a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de WinSCP"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Winscp-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Winscp-Installer $args[1] $args[2]
	}
}