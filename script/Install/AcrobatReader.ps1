$global:SOURCE_AcrobatReader = "Adobe.Acrobat.Reader.64-bit"

function AcrobatReader-Downloader([string]$chemin_dl,[string]$chemin_log){
	#R�cup�ration de la version et inscription dans le fichier de log
	$acrobatReader=winget show --id $global:SOURCE_AcrobatReader
	foreach ($version in $acrobatReader){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de Acrobat Reader
    & winget download --id $global:SOURCE_AcrobatReader -d $chemin_dl

    Add-Content $chemin_log 'Telechargement Acrobat Reader OK !'
	Add-Content $chemin_log '----------------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function AcrobatReader-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include *Acrobat*.exe | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Acrobat Reader effectuee"
        $arguments = '/sAll /rs /rps /l /re'
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel Acrobat Reader a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Acrobat Reader"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		AcrobatReader-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		AcrobatReader-Installer $args[1] $args[2]
	}
}
