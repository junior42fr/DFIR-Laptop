$global:SOURCE_Chrome = "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi"

function Chrome-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Chrome'
    Write-Host "Telechargement Chrome (environ 76Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $chrome_version = $global:SOURCE_Chrome.split("/")[-1]
	$version = 'Version :'+$chrome_version
	Add-Content $chemin_log $version
    $chrome_sauvegarde = $chemin_dl + "\" + $chrome_version

	#Telechargement de Chrome
    Invoke-WebRequest -Uri $global:SOURCE_Chrome -UseBasicParsing -OutFile $chrome_sauvegarde

	Add-Content $chemin_log 'Telechargement Chrome OK !'
	Add-Content $chemin_log '------------------------'
}

function Chrome-Installer([string]$chemin_dl,[string]$chemin_log){
    $logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include googlechrome*.msi | select FullName
    if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Google Chrome effectuee"
        $arguments = '/I ' + $logiciel.FullName + ' /quiet'
        Start-Process -Wait msiexec.exe -ArgumentList $arguments
    }
    else{
		Write-Host "Aucun logiciel Google Chrome a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Google Chrome"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Chrome-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Chrome-Installer $args[1] $args[2]
	}
}
