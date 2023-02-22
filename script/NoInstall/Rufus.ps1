$global:SOURCE_Rufus = "https://rufus.ie/downloads/"

function Rufus-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Rufus'
    Write-Host "Telechargement Rufus (1.1Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $rufus = $(@(Invoke-WebRequest -Uri $Global:SOURCE_Rufus -UseBasicParsing).links.href) -match 'p.exe'
    $rufus_dl = $rufus[0]
	$rufus_version = $rufus_dl.split("/")[-1]
    $rufus_sauvegarde = $chemin_dl + $rufus_version
	$version = 'Version :'+$rufus_version
	Add-Content $chemin_log $version

	#Telechargement de Rufus
    Invoke-WebRequest -Uri $rufus_dl -UseBasicParsing -Outfile $rufus_sauvegarde

	Add-Content $chemin_log 'Telechargement Rufus OK !'
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Rufus-Downloader $args[1] $args[2]
	}
}
