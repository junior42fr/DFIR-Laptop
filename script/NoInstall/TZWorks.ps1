$global:SOURCE_TZworks = "https://tzworks.com/download_links.php"

function TZWorks-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement TZworks'
    Write-Host "Telechargement TZworks pour Windows (environ 98Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    Write-Host "ATTENTION !!! Ceci telecharge la suite TZWORKS mais PAS LE FICHIER DE LICENCE !!" -ForegroundColor Black -BackgroundColor White
    $tzworks_niv1 = Invoke-Webrequest -Uri $global:SOURCE_TZworks -UseBasicParsing
    #Recuperation du lien de telechargement de la suite complete pour Windows
    $tzworks_niv2 = $tzworks_niv1.Links.href | Select-String "vers=win" | Select-String "typ=64" | Select-String "proto_id=32" | Out-String
    $tzworks_niv2_lien = $tzworks_niv2.split("\'")[1]
    $tzworks_niv2_lien = $tzworks_niv2_lien.Replace("&amp;","&")
    #Recuperation du lien de telechargement de la suite complete pour Windows sur la page intermediaire de User AGREEMENT
    $tzworks_niv3 = Invoke-WebRequest -Uri $tzworks_niv2_lien -UseBasicParsing
    $tzworks_niv3_lien = $tzworks_niv3.Content.Split("\'")[1] 
	$tzworks_version = "TZWorks_"+$tzworks_niv3_lien.split("/")[-1]
    $tzworks_sauvegarde = $chemin_dl + $tzworks_version
	$version = 'Version :'+$tzworks_version
	Add-Content $chemin_log $version
 
	#Telechargement de TZworks
    Invoke-WebRequest -Uri $tzworks_niv3_lien -UseBasicParsing -OutFile $tzworks_sauvegarde

	Add-Content $chemin_log 'Telechargement TZworks OK !'
	Add-Content $chemin_log '---------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		TZWorks-Downloader $args[1] $args[2]
	}
}
