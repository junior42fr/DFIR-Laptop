$global:SOURCE_Brim = "https://www.brimdata.io/download/"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Brim-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Brim'
    Write-Host "Telechargement Brim (environ 210Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $brim = Invoke-WebRequest -Uri $global:SOURCE_Brim -UseBasicParsing
    $brim_dl = ($brim.links.href -match '.exe$')[-1]
    $brim_version = $brim_dl.split("/")[-1]
	$version = 'Version :'+$brim_version
	Add-Content $chemin_log $version
    $brim_sauvegarde = $chemin_dl + $brim_version
	
	#Telechargement de Brim
    Invoke-WebRequest -Uri $brim_dl -UseBasicParsing -OutFile $brim_sauvegarde
	
	Add-Content $chemin_log 'Telechargement Brim OK !'
	Add-Content $chemin_log '------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Brim-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Brim*.exe | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Brim effectuee"

		Write-Host "Lancement" -ForegroundColor DarkBlue -BackgroundColor White
        Start-Process $logiciel.FullName
        #Attente du lancement de l'installation
        Sleep 10

        #Validation de EULA
		Write-Host "Validation EULA" -ForegroundColor DarkBlue -BackgroundColor White
        $wshell = New-Object -ComObject wscript.shell;
        $wshell.AppActivate('Installation de Brim')
        Sleep 6
        $wshell.SendKeys('~')

        #Arrêt de Brim automatiquement lancé après installation
		Write-Host "Attente de l'arrêt" -ForegroundColor DarkBlue -BackgroundColor White
        While(!$brim){
	        $brim = Get-Process brim -ErrorAction SilentlyContinue
        }
		Write-Host "Arrêt de Brim" -ForegroundColor DarkBlue -BackgroundColor White
        Stop-Process -Name Brim
 	}
	else{
		Write-Host "Aucun logiciel Brim a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Brim"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Brim-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Brim-Installer $args[1] $args[2]
	}
}
