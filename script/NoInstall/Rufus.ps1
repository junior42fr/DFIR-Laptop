$global:SOURCE_Rufus = "Rufus.Rufus"

function Rufus-Downloader([string]$chemin_dl,[string]$chemin_log){
   	#Récupération de la version et inscription dans le fichier de log
	$rufus=winget show --id $global:SOURCE_Rufus
	foreach ($version in $rufus){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de Rufus
    & winget download --id $global:SOURCE_Rufus -d $chemin_dl

	Add-Content $chemin_log 'Telechargement Rufus OK !'
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Rufus-Downloader $args[1] $args[2]
	}
}
