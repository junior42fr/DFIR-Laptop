$global:SOURCE_Firefox = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=fr"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Firefox-Downloader([string]$chemin_dl,[string]$chemin_log){
	Function Get-RedirectedUrl {
		Param (
			[Parameter(Mandatory=$true)]
			[String]$URL
		)

		$request = [System.Net.WebRequest]::Create($url)
		$request.AllowAutoRedirect=$false
		$response=$request.GetResponse()

		If ($response.StatusCode -eq "Found")
		{
			$response.GetResponseHeader("Location")
		}
	}
	
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Firefox'
    Write-Host "Telechargement Firefox (environ 55Mo)" -ForegroundColor DarkBlue -BackgroundColor White
	$firefox_dl = Get-RedirectedUrl $Global:SOURCE_Firefox
	$firefox_version = $firefox_dl.split("/")[-1].Replace('%20','_')
	$version = 'Version :'+$firefox_version
 	Add-Content $chemin_log $version
	$firefox_sauvegarde = $chemin_dl + $firefox_version
	
	#Telechargement de Firefox
    Invoke-WebRequest -Uri $firefox_dl -UseBasicParsing -OutFile $firefox_sauvegarde

	Add-Content $chemin_log 'Telechargement Firefox OK !'
	Add-Content $chemin_log '---------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Firefox-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Firefox*.exe | select FullName
	if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Firefox effectuee"
        $arguments = "-ms"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments

	}
	else{
		Write-Host "Aucun logiciel Firefox a installer" -BackgroundColor White -ForegroundColor Red
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
		Firefox-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Firefox-Installer $args[1] $args[2]
	}
}
