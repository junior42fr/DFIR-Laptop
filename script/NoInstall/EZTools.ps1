$global:SOURCE_EZTools = "https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1"

function EZTools-Downloader([string]$chemin_dl,[string]$chemin_log){
    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement EZ Tools'
    Write-Host "Telechargement des outils d'Eric Zimmerman" -ForegroundColor DarkBlue -BackgroundColor White
    $tools_zimmerman = $chemin_dl + "EZ_tools\"
    New-Item -ItemType Directory -Force -Path $tools_zimmerman
    $EZ_tools_ps1 = ".\" + $global:SOURCE_EZTools.split("/")[-1]

	#Telechargement du script powershell EZ Tools
    Invoke-WebRequest -Uri $global:SOURCE_EZTools -UseBasicParsing -Outfile $EZ_tools_ps1
    $arguments = $EZ_tools_ps1 + " -Dest " + $tools_zimmerman

	#Recuperation des EZ Tools
    Start-Process -NoNewWindow -Wait powershell.exe -ArgumentList $arguments
    Remove-Item -Force $EZ_tools_ps1

	Add-Content $chemin_log 'Telechargement EZ Tools OK !'
	Add-Content $chemin_log '---------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		EZTools-Downloader $args[1] $args[2]
	}
}
