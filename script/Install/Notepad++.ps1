$global:SOURCE_Notepad = "Notepad++.Notepad++"

function Notepad-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$notepad=winget show --id $global:SOURCE_Notepad
	foreach ($version in $notepad){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de Notepad++
    & winget download --id $global:SOURCE_Notepad -d $chemin_dl

	Add-Content $chemin_log 'Telechargement Notepad++ OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Notepad-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Notepad*.exe | select FullName
    if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Notepad++ effectuee"
        $arguments = "/S"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
    }
	else{
		Write-Host "Aucun logiciel Notepad++ a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Notepad++"
	}
	Add-Content $chemin_log '-------------------------'
}


#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Notepad-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Notepad-Installer $args[1] $args[2]
	}
}
