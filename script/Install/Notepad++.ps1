$global:SOURCE_Notepad = "https://notepad-plus-plus.org/downloads/"

function Notepad-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Notepad++'
    Write-Host "Telechargement Notepad++ (environ 5Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $notepad_niv1 = $(@(Invoke-WebRequest -Uri $global:SOURCE_Notepad -UseBasicParsing).links.href) -match "downloads"
    $notepad_niv1 = $global:SOURCE_Notepad + $notepad_niv1[0].split("/")[-2]
    $notepad_niv2 = $(@(Invoke-WebRequest -Uri $notepad_niv1 -UseBasicParsing).links.href) -match 'exe$' -match "64"
    $notepad_dl = $notepad_niv2[0]
    $notepad_version = $notepad_dl.split("/")[-1]
	$version = 'Version :'+$notepad_version
	Add-Content $chemin_log $version
    $notepad_sauvegarde = $chemin_dl + $notepad_version
	
	#Telechargement de Notepad++
    Invoke-WebRequest -Uri $notepad_dl -UseBasicParsing -OutFile $notepad_sauvegarde
	
	Add-Content $chemin_log 'Telechargement Notepad++ OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Notepad-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include npp*.exe | select FullName
    if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Notepad++ effectuee"
        $arguments = "/S"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
    }
	else{
		Write-Host "Aucun logiciel Notepad++ a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Notepad++"
	}
	Add-Content $chemin_log '-------------------------'
}


#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Notepad-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Notepad-Installer $args[1] $args[2]
	}
}
