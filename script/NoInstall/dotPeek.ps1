$global:SOURCE_dotPeek = "https://www.jetbrains.com/decompiler/download/#section=portable"

function dotPeek-Downloader([string]$chemin_dl,[string]$chemin_log){
	Function Get-RedirectedUrl {
		Param (
			[Parameter(Mandatory=$true)]
			[String]$URL
		)

		$request = [System.Net.WebRequest]::Create($url)
		$request.AllowAutoRedirect=$false
		$response=$request.GetResponse()

		If ($response.StatusCode -eq "Found")
		{
			$response.GetResponseHeader("Location")
		}
	}

    $ProgressPreference = 'SilentlyContinue'
	Add-Content $chemin_log 'Telechargement dotPeek'
    Write-Host "Telechargement .Peek (75Mo)" -ForegroundColor DarkBlue -BackgroundColor White
	[uri]$source = $global:SOURCE_dotPeek
    $dotpeek_niv1 = $(@(Invoke-WebRequest -Uri $source -UseBasicParsing).links.href) -match "windows64"
    $dotpeek_niv2 = $source.Scheme+":"+$dotpeek_niv1
	$dotpeek_dl = Get-RedirectedUrl $dotpeek_niv2
	$dotpeek_version = $dotpeek_dl.split("/")[-1]
    $dotpeek_sauvegarde = $chemin_dl + $dotpeek_version
	$version = 'Version :'+$dotpeek_version
	Add-Content $chemin_log $version
 
	#Telechargement de dotPeek
	Invoke-WebRequest -Uri $dotpeek_niv2 -UseBasicParsing -OutFile $dotpeek_sauvegarde

	Add-Content $chemin_log 'Telechargement dotPeek OK !'
	Add-Content $chemin_log '---------------------------'
}

#Fonction principale
#Parametre 1 : download ou install
#Parametre 2 : chemin de telechargement/installer
#Parametre 3 : chemin du fichier de log
if($args[0]){
    if($args[0] -match "download"){
		dotPeek-Downloader $args[1] $args[2]
	}
}
