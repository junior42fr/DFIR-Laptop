$global:SOURCE_Sysinternals = "https://download.sysinternals.com/files/SysinternalsSuite.zip"

function Sysinternals-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Sysinternals'
    Write-Host "Telechargement des outils Sysinternals (environ 45Mo)" -ForegroundColor DarkBlue -BackgroundColor White
	$Sysinternals_version = $global:SOURCE_Sysinternals.Split("/")[-1]
    $Sysinternals_sauvegarde = $chemin_dl + $Sysinternals_version
	$version = 'Version :'+$Sysinternals_version
	Add-Content $chemin_log $version

	#Telechargement de Sysinternals	
    Invoke-WebRequest -Uri $global:SOURCE_Sysinternals -UseBasicParsing -OutFile $Sysinternals_sauvegarde

	Add-Content $chemin_log 'Telechargement Sysinternals OK !'
	Add-Content $chemin_log '--------------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Sysinternals-Downloader $args[1] $args[2]
	}
}
