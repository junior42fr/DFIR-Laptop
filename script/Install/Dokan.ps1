$global:SOURCE_Dokan = "dokan-dev.Dokany"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Dokan-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$dokan=winget show --id $global:SOURCE_Dokan
	foreach ($version in $dokan){
        if ($version -match "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de Dokan
    & winget download --id $global:SOURCE_Dokan -d $chemin_dl

	Add-Content $chemin_log 'Telechargement Dokan OK !'
	Add-Content $chemin_log '---------------------------'	
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Dokan-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include *Dokan*.msi | select FullName
	if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Dokan effectuee"
        $arguments = '/I "'+ $logiciel.FullName +'" /quiet /norestart'
        Start-Process -Wait msiexec.exe -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel Dokan a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Dokan"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Dokan-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Dokan-Installer $args[1] $args[2]
	}
}
