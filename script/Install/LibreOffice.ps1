$global:SOURCE_LibreOffice = "TheDocumentFoundation.LibreOffice"

function LibreOffice-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$libreoffice=winget show --id $global:SOURCE_LibreOffice
	foreach ($version in $libreoffice){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de LibreOffice
    & winget download --id $global:SOURCE_LibreOffice -d $chemin_dl

    Add-Content $chemin_log 'Telechargement LibreOffice OK !'
	Add-Content $chemin_log '-------------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function LibreOffice-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include LibreOffice*.msi | select FullName
    if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de LibreOffice effectuee"
        $arguments = '/I ' + $logiciel.FullName + ' /norestart /qn'
        Start-Process -Wait msiexec.exe -ArgumentList $arguments
    }
	else{
		Write-Host "Aucun logiciel LibreOffice a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de LibreOffice"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		LibreOffice-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		LibreOffice-Installer $args[1] $args[2]
	}
}
