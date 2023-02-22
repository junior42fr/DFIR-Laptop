$global:SOURCE_Putty = "https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html"

function Putty-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Putty'
    Write-Host "Telechargement Putty (environ 4Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $putty = $(@(Invoke-WebRequest -Uri $global:SOURCE_Putty -UseBasicParsing).links.href) -match 'msi$' -match "64bit"
    $putty_dl = $putty[0]
    $putty_version = $putty_dl.split("/")[-1]
	$version = 'Version :'+$putty_version
	Add-Content $chemin_log $version	
    $putty_sauvegarde = $chemin_dl + $putty_version
	
	#Telechargement de Putty
    Invoke-WebRequest -Uri $putty_dl -UseBasicParsing -OutFile $putty_sauvegarde
	
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
