$global:SOURCE_Winscp = "https://winscp.net/eng/downloads.php"

function Winscp-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement WinSCP'
    Write-Host "Telechargement WinSCP (environ 12Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    [uri]$source = $global:SOURCE_Winscp
    $winscp_niv1 = Invoke-WebRequest -Uri $source.OriginalString -UseBasicParsing
    $lien_relatif = $($winscp_niv1.Links.href -match "exe")[0]
    $lien_uri = $source.Scheme+"://"+$source.Authority+$lien_relatif
    $winscp_niv2 = Invoke-WebRequest -Uri $lien_uri -UseBasicParsing
    $winscp_dl =($winscp_niv2.Links.href -match '\.exe')[0]
    $winscp_version = $winscp_dl.Split("/")[-1]
	$version = 'Version :'+$winscp_version
	Add-Content $chemin_log $version
    $winscp_sauvegarde = $chemin_dl + $winscp_version

	#Telechargement de WinSCP
    Invoke-WebRequest -Uri $winscp_dl -UseBasicParsing -OutFile $winscp_sauvegarde

	Add-Content $chemin_log 'Telechargement WinSCP OK !'
	Add-Content $chemin_log '--------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Winscp-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Winscp*.exe | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Winscp effectuee"
        $arguments = "/silent /allusers /norestart"
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
 	}
	else{
		Write-Host "Aucun logiciel WinSCP a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de WinSCP"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Winscp-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Winscp-Installer $args[1] $args[2]
	}
}