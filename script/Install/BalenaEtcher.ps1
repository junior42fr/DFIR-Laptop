$global:SOURCE_Balena = "Balena.Etcher"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Balena-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$Balena=winget show --id $global:SOURCE_Balena
	foreach ($version in $Balena){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de Balena Etcher
    & winget download --id $global:SOURCE_Balena -d $chemin_dl

    Add-Content $chemin_log 'Telechargement de Balena Etcher OK !'
	Add-Content $chemin_log '-------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Balena-Installer([string]$chemin_dl,[string]$chemin_log){
   	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include "balena*.exe" | select FullName
	if($logiciel.FullName){
                Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Balena Etcher effectuee"
        $arguments = '/S'
		Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
    }
    else{
        Write-Host "Aucun logiciel Balena Etcher a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Balena Etcher"
    }
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Balena-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Balena-Installer $args[1] $args[2]
	}
}
