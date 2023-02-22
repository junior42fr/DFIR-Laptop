$global:SOURCE_Magnet = "https://go.magnetforensics.com/e/52162/MagnetRAMCapture/kpt99x/1159627341?h=_p7MJfjQxmriHwqkj9Y5dABdthKjcoTYlYAcem6swgY"

function MRC-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Magnet RAM Capture'
    Write-Host "Telechargement Magnet RAM Capture (moins d'1Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $magnet_version = "MRCv120.exe"
    $magnet_sauvegarde = $chemin_dl + $magnet_version
	$version = 'Version :'+$magnet_version
	Add-Content $chemin_log $version

	#Telechargement de Magnet RAM Capture
    Invoke-WebRequest -Uri $global:SOURCE_Magnet -UseBasicParsing -Outfile $magnet_sauvegarde

	Add-Content $chemin_log 'Telechargement Magnet RAM Capture OK !'
	Add-Content $chemin_log '--------------------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		MRC-Downloader $args[1] $args[2]
	}
}
