$global:SOURCE_Javelin3PDFReader = "https://www.drumlinsecurity.com/javelindownloads.php"

function Javelin3PDFReader-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement Javelin3PDFReader'
    Write-Host "Telechargement Javelin3 PDF Reader (environ 14Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    [uri]$source = $Global:SOURCE_Javelin3PDFReader
    $lien_relatif = ($(@(Invoke-WebRequest -Uri $Global:SOURCE_Javelin3PDFReader -UseBasicParsing)).links.href -match '.exe$')[0]
    $javelin_dl = $source.Scheme + "://" + $source.Authority + $lien_relatif
    $javelin_version = $javelin_dl.split("/")[-1]
    $version = 'Version :'+$javelin_version
	Add-Content $chemin_log $version
    $javelin_sauvegarde = $chemin_dl + $javelin_version
	#Telechargement de Javelin3 PDF Reader
    Invoke-WebRequest -Uri $javelin_dl -UseBasicParsing -OutFile $javelin_sauvegarde

	Add-Content $chemin_log 'Telechargement Javelin3 PDF Reader OK !'
	Add-Content $chemin_log '---------------------------------------'
}

#Fonction d'installation du logiciel
#Parametre 1 : chemin de telechargement
#Parametre 2 : chemin du fichier de log
function Javelin3PDFReader-Installer([string]$chemin_dl,[string]$chemin_log){
	$logiciel = Get-ChildItem -Recurse -Path $chemin_dl -Include Javelin*.exe | select FullName
	if($logiciel.FullName){
		Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        Add-Content $chemin_log "Installation de Javelin3 PDF Reader effectuee"
        $arguments = '/SILENT'
        Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
	}
	else{
		Write-Host "Aucun logiciel Javelin3 PDF Reader a installer" -BackgroundColor White -ForegroundColor Red
        Add-Content $chemin_log "Echec de l'installation de Javelin3 PDF Reader"
	}
	Add-Content $chemin_log '-------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		Javelin3PDFReader-Downloader $args[1] $args[2]
	}

	if($args[0] -match "install"){
		Javelin3PDFReader-Installer $args[1] $args[2]
	}
}
