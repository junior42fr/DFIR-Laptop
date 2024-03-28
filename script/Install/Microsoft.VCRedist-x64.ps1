$global:SOURCE_VCRedist = "Microsoft.VCRedist.2015+.x64"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function VCRedist-Downloader([string]$chemin_dl,[string]$chemin_log){
 	#Récupération de la version et inscription dans le fichier de log
	$vcredist=winget show --id $global:SOURCE_VCRedist
	foreach ($version in $vcredist){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de VCRedist
    & winget download --id $global:SOURCE_VCRedist -d $chemin_dl
		
    Add-Content $chemin_log 'Telechargement VCRedist-x64 OK !'
	Add-Content $chemin_log '------------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function VCRedist-Installer([string]$chemin_dl,[string]$chemin_log){
   	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include *Visual*2015-2022*x64*.exe | select FullName
	if($logiciel.FullName){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
		$arguments = '/passive /install'
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
        Add-Content $chemin_log "Installation de VCRedist-x64 effectuee"
    }
    else{
        Write-Host "Aucun logiciel VCRedist-x86 a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Aucun logiciel VCRedist-x64 a installer"
    }
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		VCRedist-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		VCRedist-Installer $args[1] $args[2]
	}
}
