$global:SOURCE_DBBrowser = "DBBrowserForSQLite.DBBrowserForSQLite"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function DBBrowser-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$dbbrowser=winget show --id $global:SOURCE_DBBrowser
	foreach ($version in $dbbrowser){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de DBBrowser
    & winget download --id $global:SOURCE_DBBrowser -d $chemin_dl

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
        $arguments = '/I "'+ $logiciel.FullName +'" SHORTCUT_SQLITE_PROGRAMMENU=1 SHORTCUT_SQLCIPHER_PROGRAMMENU=1 SHORTCUT_SQLITE_DESKTOP=1 SHORTCUT_SQLCIPHER_DESKTOP=1 /quiet /norestart'
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
