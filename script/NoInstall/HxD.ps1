$global:SOURCE_HxD = "MHNexus.HxD"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function HxD-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$hxd=winget show --id $global:SOURCE_HxD
	foreach ($version in $hxd){
        if ($version -match "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de HxD
    & winget download --id $global:SOURCE_HxD -d $chemin_dl

	Add-Content $chemin_log 'Telechargement HxD OK !'
	Add-Content $chemin_log '-----------------------'	
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function HxD-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include *HxD*.msi | select FullName
	if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de HxD effectuee"
        $arguments = '/I "'+ $logiciel.FullName +'" /quiet /norestart'
        Start-Process -Wait msiexec.exe -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel HxD a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de HxD"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		HxD-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		HxD-Installer $args[1] $args[2]
	}
}
