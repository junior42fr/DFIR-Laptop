$global:SOURCE_NPCap = "Insecure.Npcap"

function Npcap-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$npcap=winget show --id $global:SOURCE_NPCap
	foreach ($version in $npcap){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de NpCap
    & winget download --id $global:SOURCE_NPCap -d $chemin_dl

	Add-Content $chemin_log 'Telechargement NPCap OK !'
	Add-Content $chemin_log '-------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Npcap-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include *Npcap*.exe | select FullName
    if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de NPcap effectuee"
        $arguments = "/S"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
    }
	else{
		Write-Host "Aucun logiciel NPCap a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de NPCap"
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
