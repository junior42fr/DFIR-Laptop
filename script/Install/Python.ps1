$global:SOURCE_Python = "https://www.python.org/downloads/release/python-395/"

function Python-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Telechargement Python (environ 28Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $python = $(@(Invoke-WebRequest -Uri $global:SOURCE_Python -UseBasicParsing).links.href) -match 'exe$' -match "64"
    $python_dl = $python[0]
    $python_version = $python_dl.Split("/")[-1]
	$version = 'Version :'+$python_version
	Add-Content $chemin_log $version
    $python_sauvegarde = $chemin_dl + $python_version

	#Telechargement de Python
    Invoke-WebRequest -Uri $python_dl -UseBasicParsing -OutFile $python_sauvegarde

	Add-Content $chemin_log 'Telechargement Python OK !'
	Add-Content $chemin_log '--------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Python-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include python*.exe | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Python effectuee"
        $arguments = "/quiet InstallAllUsers=1 PrependPath=1"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel Python a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Python"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Python-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Python-Installer $args[1] $args[2]
	}
}