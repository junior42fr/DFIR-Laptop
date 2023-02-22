$global:SOURCE_Comodo = "https://www.comodo.com/home/download/during-download.php?prod=CRD"

function Comodo-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Comodo Rescue Disk'
    Write-Host "Telechargement Comodo (environ 51Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $comodo_niv1 = Invoke-WebRequest -Uri $global:SOURCE_Comodo -UseBasicParsing
    $comodo_dl = $comodo_niv1.links.href -match "iso"
    $comodo_version = $comodo_dl[0].split("/")[-1]
	$version = 'Version :'+$comodo_version
	Add-Content $chemin_log $version
    $comodo_sauvegarde = $chemin_dl + $comodo_version

	#Telechargement de Comodo Rescue Disk
    Invoke-WebRequest -Uri $comodo_dl[0]-UseBasicParsing -OutFile $comodo_sauvegarde

	Add-Content $chemin_log 'Telechargement Comodo Rescue Disk OK !'
	Add-Content $chemin_log '--------------------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Comodo-Downloader $args[1] $args[2]
	}
}
