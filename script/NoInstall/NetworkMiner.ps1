$global:SOURCE_NetworkMiner = "https://www.netresec.com/?download=NetworkMiner"

function NetworkMiner-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement NetworkMiner'
    Write-Host "Telechargement NetworkMiner (2.5Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $networkminer_sauvegarde = $chemin_dl + "networkminer.zip"

	#Telechargement de NetworkMiner
    Invoke-WebRequest -Uri $global:SOURCE_NetworkMiner -UseBasicParsing -OutFile $networkminer_sauvegarde

	Add-Content $chemin_log 'Telechargement NetworkMiner OK !'
	Add-Content $chemin_log '--------------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		NetworkMiner-Downloader $args[1] $args[2]
	}
}
