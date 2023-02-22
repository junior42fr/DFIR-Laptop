$global:SOURCE_Plaso = "https://github.com/log2timeline/plaso/releases/download/20191203/plaso-20191203-py3.7-amd64.zip"

function Plaso-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Plaso'
    Write-Host "Telechargement de Plaso for Windows (43Mo)" -ForegroundColor DarkBlue -BackgroundColor White
	$plaso_version = $Global:SOURCE_Plaso.Split("/")[-1]
	$plaso_sauvegarde = $chemin_dl + $plaso_version
	$version = 'Version :'+$plaso_version
	Add-Content $chemin_log $version

	#Telechargement de Plaso
    Invoke-WebRequest -Uri $global:SOURCE_Plaso -UseBasicParsing -OutFile $plaso_sauvegarde

	Add-Content $chemin_log 'Telechargement Plaso OK !'
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Plaso-Downloader $args[1] $args[2]
	}
}
