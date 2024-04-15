$global:SOURCE_dnSpy = "dnSpyEx.dnSpy"

function dnSpy-Downloader([string]$chemin_dl,[string]$chemin_log){
	#Récupération de la version et inscription dans le fichier de log
	$dotnet=winget show --id $global:SOURCE_dnSpy
	foreach ($version in $dnspy){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de dnSpy
    & winget download --id $global:SOURCE_dnSpy -d $chemin_dl

    Add-Content $chemin_log 'Telechargement de dnSpy OK !'
	Add-Content $chemin_log '----------------------------------'
}


#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		dnSpy-Downloader $args[1] $args[2]
	}
}
