$global:SOURCE_Python = "Python.Python.3.12"

function Python-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$python=winget show --id $global:SOURCE_Python
	foreach ($version in $python){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de Python
    & winget download --id $global:SOURCE_Python -d $chemin_dl

	Add-Content $chemin_log 'Telechargement Python OK !'
	Add-Content $chemin_log '--------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Python-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include python*.exe | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Python effectuee"
        $arguments = "/quiet InstallAllUsers=1 PrependPath=1"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel Python a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Python"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Python-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Python-Installer $args[1] $args[2]
	}
}