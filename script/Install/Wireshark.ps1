$global:SOURCE_Wireshark = "https://www.wireshark.org/download.html"

function Wireshark-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Wireshark'
    Write-Host "Telechargement Wireshark (environ 80Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $wireshark = $(@(invoke-Webrequest -Uri $global:SOURCE_Wireshark -UseBasicParsing).links.href) -match "exe" -match "win64"
    $wireshark_dl = $wireshark[0]
    $wireshark_version = $wireshark_dl.split("/")[-1]
	$version = 'Version :'+$wireshark_version
	Add-Content $chemin_log $version
    $wireshark_sauvegarde = $chemin_dl + $wireshark_version

	#Telechargement de Wireshark
    Invoke-WebRequest -Uri $wireshark_dl -UseBasicParsing -OutFile $wireshark_sauvegarde

	Add-Content $chemin_log 'Telechargement Wireshark OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Wireshark-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Wireshark*.exe | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Wireshark effectuee"
        $arguments = "/S"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel Wireshark a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Wireshark"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Wireshark-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Wireshark-Installer $args[1] $args[2]
	}
}