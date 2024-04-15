$global:SOURCE_TestDisk = "CGSecurity.TestDisk"

function TestDisk-Downloader([string]$chemin_dl,[string]$chemin_log){
   	#Récupération de la version et inscription dans le fichier de log
	$testdisk=winget show --id $global:SOURCE_TestDisk
	foreach ($version in $testdisk){
        if ($version -like "Version*"){
            Add-Content $chemin_log $version
		}
	}

	#Telechargement de Test Disk
    & winget download --id $global:SOURCE_TestDisk -d $chemin_dl

	Add-Content $chemin_log 'Telechargement TestDisk OK !'
	Add-Content $chemin_log '----------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		TestDisk-Downloader $args[1] $args[2]
	}
}
