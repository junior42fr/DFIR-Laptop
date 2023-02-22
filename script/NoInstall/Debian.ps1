$global:SOURCE_Debian = "https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/"

function Debian-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Debian'
    Write-Host "Telechargement Debian Live (1.2Go)" -ForegroundColor DarkBlue -BackgroundColor White
    $debian = $(@(Invoke-Webrequest -Uri $global:SOURCE_Debian -UseBasicParsing)).links.href -match "standard.iso"
    $debian_version = $debian[0]
    $debian_dl = $global:SOURCE_Debian + $debian_version
	$version = 'Version :'+$debian_version
	Add-Content $chemin_log $version
    $debian_sauvegarde = $chemin_dl + $debian_version

	#Telechargement de Debian
    Invoke-WebRequest -Uri $debian_dl -UseBasicParsing -OutFile	$debian_sauvegarde

	Add-Content $chemin_log 'Telechargement Debian OK !'
	Add-Content $chemin_log '--------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Debian-Downloader $args[1] $args[2]
	}
}
