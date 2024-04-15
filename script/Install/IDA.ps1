$global:SOURCE_IDA = "Hex-Rays.IDA.Free"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function IDA-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$IDA=winget show --id $global:SOURCE_IDA
	foreach ($version in $IDA){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de IDA Freeware
    & winget download --id $global:SOURCE_IDA -d $chemin_dl

    Add-Content $chemin_log 'Telechargement de IDA Freeware OK !'
	Add-Content $chemin_log '-------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function IDA-Installer([string]$chemin_dl,[string]$chemin_log){
   	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include "IDA *.exe" | select FullName
	if($logiciel.FullName){
                Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de IDA Freeware effectuee"
        $arguments = '--mode unattended --unattendedmodeui none'
		Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
    }
    else{
        Write-Host "Aucun logiciel IDA a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de IDA"
    }
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		IDA-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		IDA-Installer $args[1] $args[2]
	}
}
