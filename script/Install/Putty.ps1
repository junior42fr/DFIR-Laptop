$global:SOURCE_Putty = "PuTTY.PuTTY"

function Putty-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$putty=winget show --id $global:SOURCE_Putty
	foreach ($version in $putty){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de Putty
    & winget download --id $global:SOURCE_Putty -d $chemin_dl

	Add-Content $chemin_log 'Telechargement Putty OK !'
	Add-Content $chemin_log '-------------------------'	
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Putty-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include putty*.msi | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Putty effectuee"
        $arguments = '/I ' + $logiciel.FullName + ' /quiet'
        Start-Process -Wait msiexec.exe -ArgumentList $arguments
    }
	else{
		Write-Host "Aucun logiciel Putty a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Putty"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Putty-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Putty-Installer $args[1] $args[2]
	}
}
