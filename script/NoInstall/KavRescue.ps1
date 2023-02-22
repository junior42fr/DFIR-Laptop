$global:SOURCE_Kavrescue = "https://support.kaspersky.com/14226"

function KavRescue-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement KavRescue'
    Write-Host "Telechargement de Kavrescue (650Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $kavrescue = $(@(Invoke-WebRequest -Uri $global:SOURCE_Kavrescue -UseBasicParsing).links.href) -match 'iso$'
    $kavrescue_dl = $kavrescue[0]
	$kavrescue_version = $kavrescue_dl.split("/")[-1]
    $kavrescue_sauvegarde = $chemin_dl + $kavrescue_version
	$version = 'Version :'+$kavrescue_version
	Add-Content $chemin_log $version

	#Telechargement de KavRescue
    Invoke-WebRequest -Uri $kavrescue_dl -UseBasicParsing -OutFile $kavrescue_sauvegarde

	Add-Content $chemin_log 'Telechargement KavRescue OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		KavRescue-Downloader $args[1] $args[2]
	}
}
