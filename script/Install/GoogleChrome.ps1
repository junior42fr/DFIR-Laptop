$global:SOURCE_Chrome = "Google.Chrome"

function Chrome-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$chrome=winget show --id $global:SOURCE_Chrome
	foreach ($version in $chrome){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de Google Chrome
    & winget download --id $global:SOURCE_Chrome -d $chemin_dl

	Add-Content $chemin_log 'Telechargement Google Chrome OK !'
	Add-Content $chemin_log '------------------------'
}

function Chrome-Installer([string]$chemin_dl,[string]$chemin_log){
    $logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include *chrome*.exe | select FullName
    if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Google Chrome effectuee"
        $arguments = '--do-not-launch-chrome'
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
    }
    else{
		Write-Host "Aucun logiciel Google Chrome a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Google Chrome"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Chrome-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Chrome-Installer $args[1] $args[2]
	}
}
