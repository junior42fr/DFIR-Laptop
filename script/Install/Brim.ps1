$global:SOURCE_Brim = "brimdata.brim"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Brim-Downloader([string]$chemin_dl,[string]$chemin_log){
    #Récupération de la version et inscription dans le fichier de log
    Add-Content $chemin_log "Fonction Téléchargement de Zui/Brim"
    $brim=winget show --id $global:SOURCE_Brim
    foreach ($version in $brim){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
        }
    }

    #Telechargement de Brim
    Add-Content $chemin_log "Lancement Téléchargement de Zui/Brim"
    & winget download --id $global:SOURCE_Brim -d $chemin_dl
	
    Add-Content $chemin_log 'Telechargement Brim/Zui OK !'
    Add-Content $chemin_log '----------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Brim-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Brim*.exe | select FullName
	if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Brim/Zui effectuee"
		& $logiciel.FullName /S
    }
    else{
        Write-Host "Aucun logiciel Brim/Zui a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Brim/Zui"
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
