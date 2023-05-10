$global:SOURCE_KAPE = "https://s3.amazonaws.com/cyb-us-prd-kape/kape.zip"

function KAPE-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement KAPE'
    Write-Host "Telechargement KAPE (environ 135Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $KAPE_version = $global:SOURCE_KAPE.Split("/")[-1]
	$version = 'Version :'+$KAPE_version
	Add-Content $chemin_log $version
    $KAPE_sauvegarde = $chemin_dl + $KAPE_version

	#Telechargement de KAPE
    Invoke-WebRequest -Uri $global:SOURCE_KAPE -UseBasicParsing -OutFile $KAPE_sauvegarde

	Add-Content $chemin_log 'Telechargement KAPE OK !'
	Add-Content $chemin_log '------------------------'
	
	Expand-Archive -Force -DestinationPath $chemin_dl $KAPE_sauvegarde
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		KAPE-Downloader $args[1] $args[2]
	}
}
