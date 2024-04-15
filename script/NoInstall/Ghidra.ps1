$global:SOURCE_Ghidra = "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.0.1_build/ghidra_11.0.1_PUBLIC_20240130.zip"

#Fonction de telechargement du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Ghidra-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Ghidra (400Mo)'
    Write-Host "Telechargement Ghidra" -ForegroundColor DarkBlue -BackgroundColor White
    $ghidra = $global:SOURCE_Ghidra
    $ghidra_version = $ghidra.split("/")[-1]
	$version = 'Version :'+$ghidra_version
	Add-Content $chemin_log $version
    $ghidra_sauvegarde = $chemin_dl + $ghidra_version
	
	#Telechargement de Ghidra
    Invoke-WebRequest -Uri $ghidra -UseBasicParsing -OutFile $ghidra_sauvegarde
	
	Add-Content $chemin_log 'Telechargement Ghidra OK !'
	Add-Content $chemin_log '-----------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Ghidra-Downloader $args[1] $args[2]
	}
}
