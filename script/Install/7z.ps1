$global:SOURCE_7Zip = "https://www.7-zip.org/download.html"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function 7z-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
    Add-Content $chemin_log 'Telechargement 7-Zip'
    Write-Host "Telechargement 7-Zip (environ 1.7Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $7zip = $(@(Invoke-WebRequest -Uri $global:SOURCE_7Zip -UseBasicParsing).links.href) -match "64" -match 'exe$'
    $7zip_dl = $global:SOURCE_7Zip.split("/")[2] + "/" + $7zip[0]
    $7zip_version = $7zip_dl.Split("/")[-1]
	$version = 'Version :'+$7zip_version
	Add-Content $chemin_log $version
    $7zip_sauvegarde = $installation.chemin_logiciels + $7zip_version

	#Telechargement de 7-zip
    Invoke-WebRequest -Uri $7zip_dl -UseBasicParsing -OutFile $7zip_sauvegarde

    Add-Content $chemin_log 'Telechargement 7-Zip OK !'
	Add-Content $chemin_log '-------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function 7z-Installer([string]$chemin_dl,[string]$chemin_log){
   	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include 7z*.exe | select FullName
	if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de 7-Zip effectuee"
		& $logiciel.FullName /S
    }
    else{
        Write-Host "Aucun logiciel 7-zip a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de 7-Zip"
    }
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		7z-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		7z-Installer $args[1] $args[2]
	}
}
