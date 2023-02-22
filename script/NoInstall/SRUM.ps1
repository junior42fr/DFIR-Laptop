$global:SOURCE_SRUM = "https://github.com/MarkBaggett/srum-dump/archive/refs/heads/master.zip"

function SRUM-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement SRUM (System Resource Utilization Management Dump)'
    Write-Host "Telechargement de System Resource Utilization Management Dump (SRUM) (environ 11Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $SRUM_sauvegarde = $chemin_dl + "SRUM_DUMP_master.zip"

	#Telechargement de SRUM-Dump
    Invoke-WebRequest -Uri $global:SOURCE_SRUM -UseBasicParsing -OutFile $SRUM_sauvegarde

	Add-Content $chemin_log 'Telechargement SRUM (System Resource Utilization Management Dump) OK !'
	Add-Content $chemin_log '----------------------------------------------------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		SRUM-Downloader $args[1] $args[2]
	}
}
