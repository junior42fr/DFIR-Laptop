$global:SOURCE_Startech = "https://sgcdn.startech.com/005329/media/sets/asix_moschip-mcs7830_drivers/asix_mcs7830.zip"

function StarTech-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement StarTech USB2106S'
    Write-Host "Telechargement des drivers StarTech USB2106S (environ 33Mo)" -ForegroundColor DarkBlue -BackgroundColor White
	$startech_version = "startech_USB2106S.zip"
    $startech_sauvegarde = $chemin_dl + $startech_version
	$version = 'Version :'+$startech_version
	Add-Content $chemin_log $version
 
	#Telechargement de StarTech USB2106S
    Invoke-WebRequest -Uri $global:SOURCE_Startech -UseBasicParsing -OutFile $startech_sauvegarde

	Add-Content $chemin_log 'Telechargement StarTech USB2106S OK !'
	Add-Content $chemin_log '-------------------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		StarTech-Downloader $args[1] $args[2]
	}
}
