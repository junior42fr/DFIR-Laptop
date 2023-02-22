$global:SOURCE_NPCap = "https://nmap.org/npcap/dist/"

function Npcap-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement NPCap'
    Write-Host "Telechargement Npcap (moins de 1Mo)" -foregroundcolor DarkBlue -backgroundcolor White
    $npcap = $(@(Invoke-WebRequest -Uri $global:SOURCE_NPCap -UseBasicParsing).links.href -match 'npcap' -match 'exe$' -notmatch "nmap")
    $npcap_version = $npcap[0]
    $npcap_dl = $global:SOURCE_NPCap + $npcap_version
	$version = 'Version :'+$npcap_version
	Add-Content $chemin_log $version
    $npcap_sauvegarde = $chemin_dl + $npcap_version

	#Telechargement de NPCap
    Invoke-WebRequest -Uri $npcap_dl -UseBasicParsing -OutFile $npcap_sauvegarde

	Add-Content $chemin_log 'Telechargement NPCap OK !'
	Add-Content $chemin_log '-------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Npcap-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Npcap*.exe | select FullName
	if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Write-Host "ATTENTION VOUS DEVREZ PATIENTER PENDANT 45 SECONDES POUR L'INSTALLATION" -ForegroundColor DarkBlue -BackgroundColor Green
        Add-Content $chemin_log "Installation de Npcap effectuee"
        Start-Process $logiciel.FullName

        #Attente du lancement de l'installation
        Sleep 3
        $wshell = New-Object -ComObject wscript.shell;
        $wshell.AppActivate('Installation de Npcap')
        Sleep 1

        #Validation de EULA
        $wshell.SendKeys('~')
        #Options d'installation
        Sleep 1
        $wshell.SendKeys('~')
        #Validation d'installation
        Sleep 30
        $wshell.SendKeys('~')
        #Fin de l'installation
        Sleep 1
        $wshell.SendKeys('~')
	}
	else{
		Write-Host "Aucun logiciel Npcap a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Npcap"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Npcap-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Npcap-Installer $args[1] $args[2]
	}
}
