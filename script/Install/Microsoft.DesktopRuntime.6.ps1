$global:SOURCE_DesktopRuntime = "Microsoft.DotNet.DesktopRuntime.6"

function DesktopRuntime-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$desktopruntime=winget show --id $global:SOURCE_DesktopRuntime
	foreach ($version in $desktopruntime){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de DesktopRuntime 6
    & winget download --id $global:SOURCE_DesktopRuntime -d $chemin_dl

	Add-Content $chemin_log 'Telechargement Desktop Runtime 6 OK !'
	Add-Content $chemin_log '-------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function DesktopRuntime-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include *"Desktop Runtime"*.exe | select FullName
    if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Desktop Runtime effectuee"
        $arguments = "/quiet /norestart"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
    }
	else{
		Write-Host "Aucun logiciel Desktop Runtime a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Desktop Runtime"
	}
	Add-Content $chemin_log '-------------------------'
}


#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		DesktopRuntime-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		DesktopRuntime-Installer $args[1] $args[2]
	}
}
