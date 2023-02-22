$global:SOURCE_Eset = "https://download.eset.com/com/eset/tools/recovery/rescue_cd/latest/eset_sysrescue_live_enu.iso"

function Eset-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Eset Rescue Disk'
    Write-Host "Telechargement Eset Live Antivirus (environ 750Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $eset_version = $global:SOURCE_Eset.Split("/")[-1]
    $eset_sauvegarde = $chemin_dl + $eset_version
	$version = 'Version :'+$eset_version
	Add-Content $chemin_log $version
    Invoke-WebRequest -Uri $global:SOURCE_Eset -UseBasicParsing -OutFile $eset_sauvegarde

	Add-Content $chemin_log 'Telechargement Eset Rescue Disk OK !'
	Add-Content $chemin_log '------------------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Eset-Downloader $args[1] $args[2]
	}
}
