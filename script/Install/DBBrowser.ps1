$global:SOURCE_DBBrowser = "https://sqlitebrowser.org/dl/"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function DBBrowser-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement DBBrowser'
    Write-Host "Telechargement DB Browser for SQLite (environ 17Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $dbbrowser = $(@(Invoke-WebRequest -Uri $global:SOURCE_DBBrowser -UseBasicParsing).links.href) -match 'msi$' -match "win64"
    $dbbrowser_dl = $dbbrowser[-1]
    $dbbrowser_version = $dbbrowser_dl.split("/")[-1]
	$version = 'Version :'+$dbbrowser_version
	Add-Content $chemin_log $version
    $dbbrowser_sauvegarde = $chemin_dl+"\"+ $dbbrowser_version

	#Telechargement de DBBrowser
    Invoke-WebRequest -Uri $dbbrowser_dl -UseBasicParsing -OutFile $dbbrowser_sauvegarde

	Add-Content $chemin_log 'Telechargement DBBrowser OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function DBBrowser-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include DB*.msi | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de DBBrowser effectuee"
        $arguments = '/I '+ $logiciel.FullName +' SHORTCUT_SQLITE_PROGRAMMENU=1 SHORTCUT_SQLCIPHER_PROGRAMMENU=1 SHORTCUT_SQLITE_DESKTOP=1 SHORTCUT_SQLCIPHER_DESKTOP=1 /quiet'
        Start-Process -Wait msiexec.exe -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel DBBrowser a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de DBBrowser"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		DBBrowser-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		DBBrowser-Installer $args[1] $args[2]
	}
}
