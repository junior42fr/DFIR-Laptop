$global:SOURCE_Cyberchef = "https://github.com/gchq/CyberChef/releases/download/v9.55.0/CyberChef_v9.55.0.zip"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Cyberchef-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Cyberchef'
    Write-Host "Telechargement Cyberchef" -ForegroundColor DarkBlue -BackgroundColor White
    $cyberchef = $global:SOURCE_Cyberchef
    $cyberchef_version = $cyberchef.split("/")[-1]
	$version = 'Version :'+$cyberchef_version
	Add-Content $chemin_log $version
    $cyberchef_sauvegarde = $chemin_dl + $cyberchef_version
	
	#Telechargement de Cyberchef
    Invoke-WebRequest -Uri $cyberchef -UseBasicParsing -OutFile $cyberchef_sauvegarde
	
	Add-Content $chemin_log 'Telechargement Cyberchef OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Cyberchef-Downloader $args[1] $args[2]
	}
}
