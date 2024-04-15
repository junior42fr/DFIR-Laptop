$global:SOURCE_TeraCopy = "CodeSector.TeraCopy"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function TeraCopy-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$teracopy=winget show --id $global:SOURCE_TeraCopy
	foreach ($version in $teracopy){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de TeraCopy
    & winget download --id $global:SOURCE_TeraCopy -d $chemin_dl

	Add-Content $chemin_log 'Telechargement TeraCopy OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function TeraCopy-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include "TeraCopy*.exe" | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de TeraCopy effectuee"
        $arguments = '/exenoupdates /q'
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel TeraCopy a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de TeraCopy"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		TeraCopy-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		TeraCopy-Installer $args[1] $args[2]
	}
}
