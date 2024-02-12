$global:SOURCE_7Zip = "7zip.7zip"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function 7z-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$7zip=winget show --id $global:SOURCE_7Zip
	foreach ($version in $7zip){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de 7-zip
    & winget download --id $global:SOURCE_7Zip -d $chemin_dl

    Add-Content $chemin_log 'Telechargement 7-Zip OK !'
	Add-Content $chemin_log '-------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function 7z-Installer([string]$chemin_dl,[string]$chemin_log){
   	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include 7-Zip*.exe | select FullName
	if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de 7-Zip effectuee"
		& $logiciel.FullName /S
    }
    else{
        Write-Host "Aucun logiciel 7-zip a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de 7-Zip"
    }
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		7z-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		7z-Installer $args[1] $args[2]
	}
}
