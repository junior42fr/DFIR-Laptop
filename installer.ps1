### VARIABLES GLOBALES ###
$global:TYPE_FORENSIC = "Forensic"
$global:DISTRIB_FORENSIC = "Ubuntu"
$global:REPERTOIRE_OVA = "VirtualBoxForensic"
$global:NOM_BASE_VM = "Forensic"
$global:VIRTUALBOX = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

### URL DE TELECHARGEMENT ###
$global:SOURCE_7Zip = "https://www.7-zip.org/download.html"
$global:SOURCE_Brim = "https://www.brimdata.io/download/"
$global:SOURCE_Chrome = "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi"
$global:SOURCE_DBBrowser = "https://sqlitebrowser.org/dl/"
$global:SOURCE_Firefox = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=fr"
$global:SOURCE_Foxit = "https://www.foxit.com/downloads/latest.html?product=Foxit-Reader&platform=Windows&version=&package_type=&language=French&distID="
$global:SOURCE_HexEditor = "https://www.hhdsoftware.com/download/free-hex-editor-neo.exe"
$global:SOURCE_LibreOffice = "https://download.documentfoundation.org/libreoffice/stable/"
$global:SOURCE_Notepad = "https://notepad-plus-plus.org/downloads/"
$global:SOURCE_NPCap = "https://nmap.org/npcap/dist/"
$global:SOURCE_Packer = "https://developer.hashicorp.com/packer/downloads"
$global:SOURCE_Putty = "https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html"
$global:SOURCE_Python = "https://www.python.org/downloads/release/python-395/"
$global:SOURCE_VirtualBox = "https://www.virtualbox.org/wiki/Downloads"
$global:SOURCE_VirtualBoxExtPack = "https://www.virtualbox.org/wiki/Downloads"
$global:SOURCE_VLC = "https://ftp.free.org/mirrors/videolan/vlc/"
$global:SOURCE_Winscp = "https://winscp.net/eng/downloads.php"
$global:SOURCE_Wireshark = "https://www.wireshark.org/download.html"

$global:SOURCE_Aten = "https://assets.aten.com/product/driver/dw/uc232a_windows_setup_v1.0.087.zip"
$global:SOURCE_Balena = "https://github.com/balena-io/etcher/releases"
$global:SOURCE_Comodo = "https://www.comodo.com/home/download/during-download.php?prod=CRD"
$global:SOURCE_Debian = "https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/"
$global:SOURCE_dotPeek = "https://www.jetbrains.com/decompiler/download/#section=portable"
$global:SOURCE_Eset = "https://download.eset.com/com/eset/tools/recovery/rescue_cd/latest/eset_sysrescue_live_enu.iso"
$global:SOURCE_EZTools = "https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1"
$global:SOURCE_Kavrescue = "https://support.kaspersky.com/14226"
$global:SOURCE_Magnet = "https://go.magnetforensics.com/e/52162/MagnetRAMCapture/kpt99x/1159627341?h=_p7MJfjQxmriHwqkj9Y5dABdthKjcoTYlYAcem6swgY"
$global:SOURCE_NetworkMiner = "https://www.netresec.com/?download=NetworkMiner"
$global:SOURCE_Plaso = "https://github.com/log2timeline/plaso/releases/download/20191203/plaso-20191203-py3.7-amd64.zip"
$global:SOURCE_Rufus = "https://rufus.ie/downloads/"
$global:SOURCE_Startech = "https://sgcdn.startech.com/005329/media/sets/asix_moschip-mcs7830_drivers/asix_mcs7830.zip"
$global:SOURCE_TestDisk = "https://www.cgsecurity.org/wiki/TestDisk_Download"
$global:SOURCE_TZworks = "https://tzworks.com/download_links.php"
$global:SOURCE_WindowsDefender = "https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64"

### REPERTOIRES FORENSIC WINDOWS ###
$Chemin_forensic = "D:\_Forensic\"
$Chemin_forensic_dumps = $chemin_forensic + "dumps\"
$Chemin_forensic_extract = $chemin_forensic + "extract\"
$Chemin_forensic_tools = $chemin_forensic + "tools\"


### CLASSE PERSONNALISEE ###
#Classe pour une installation
Class CInstallation{
    [boolean]$online                 #accès à internet
    [boolean]$export                 #exportation pour une future installation hors-ligne
    [boolean]$nettoyage              #suppression de toutes traces sur le PC actuel
    [string]$ipaddress               #adresse IP du PC hôte
    [string]$chemin_base             #chemin de l'exécution du script PS1
    [string]$chemin_script           #chemin de l'exécution pour les scripts Linux Forensic
    [string]$chemin_script_forensic  #chemin complet vers le script forensic 
    [string]$chemin_script_preseed   #chemin complet vers le fichier preseed
    [string]$chemin_script_ubuntu    #chemin complet vers le fichier json pour packer ubuntu
    [string]$chemin_script_variables #chemin complet vers le fichier de variables pour packer
    [string]$chemin_repertoire_VM    #chemin du repertoire en lien avec la VM
    [string]$nom_vm                  #nom de la VM
    [string]$nom_ova                 #nom du fichier OVA associé à la VM
    [string]$chemin_ova              #chemin complet vers l'OVA de la VM
    [string]$chemin_logiciels        #chemin des logiciels hors-ligne
    [string]$chemin_export           #chemin pour l'exportation des éléments le cas échéant

    ### Méthode de demande des choix utilisateur ###
    CInstallation($chemin_base){
        #Vérification de la connexion internet
        Write-Host "Vérification de la connexion Internet (via ping)" -foregroundcolor DarkGreen -backgroundcolor White

        $ip = Get-NetIPAddress -AddressState Preferred -AddressFamily IPv4 | Select-Object IPAddress,InterfaceAlias |Where-Object { $_.InterfaceAlias -contains "Ethernet" }
        if(-not($ip)){
            $ip = Get-NetIPAddress -AddressState Preferred -AddressFamily IPv4 | Select-Object IPAddress,InterfaceAlias |Where-Object { $_.InterfaceAlias -contains "Wi-Fi" }
        }
        if($ip){
            if ($ip.IPAddress -match '^169.254.'){
                $this.online = $false
                $this.ipaddress = "0.0.0.0"
            }
            else{
                $this.ipaddress = $ip.IPAddress
                if (Test-Connection "www.google.fr" -Count 1 -Quiet){
                     $this.online = $true
                }
                else{
                    $this.online = $false
                }
            }
        }
        else{
            Write-Host "Aucune carte réseau n'est connectée à Internet" -ForegroundColor DarkRed -BackgroundColor White
        }

        $Host_method = Get-Host

        #Définition du chemin contenant les scripts d'installation
        $this.chemin_base=$chemin_base + "\"

        $this.chemin_script = $this.chemin_base + "script\"
        $this.chemin_script_forensic = $this.chemin_script + "forensic.sh"
        $this.chemin_script_preseed = $this.chemin_script + "preseed.cfg"
        $this.chemin_script_ubuntu = $this.chemin_script + "ubuntu.json"
        $this.chemin_script_variables = $this.chemin_script + "variables.json"

        #Définition du chemin de la future VM exportée
        $this.chemin_repertoire_VM = $this.chemin_base + $global:REPERTOIRE_OVA + "\"
        $date_export = Get-Date -Format "yyyy-MM-dd"
        $this.nom_vm = $global:NOM_BASE_VM + "_" + $date_export

        $this.nom_ova = $this.nom_vm + ".ova"
        $this.chemin_ova = $this.chemin_repertoire_VM + $this.nom_ova

        #Définition du chemin des logiciels Windows
        $this.chemin_logiciels = $this.chemin_base + "logiciels\"

        #Si on est connecté à internet, on demande si l'utilisateur veut exporter le résultat
        if ($this.online){
            $titre = "Exportation"
            $question = 'Voulez-vous exporter le résultat ?'
            $choix_export  = '&Non', '&Oui'

            $this.export = [System.Convert]::ToBoolean($Host_method.UI.PromptForChoice($titre, $question, $choix_export, 0))
        }

        #Si l'utilisateur veut exporter le résultat, on demande s'il veut remettre le PC en config d'origine à la fin
        if ($this.export -eq $true){
            $this.chemin_export = $this.chemin_base + "EXPORTATION\"

            $titre = "Restauration"
            $question = "Voulez-vous nettoyer la machine hôte à l'issue?"
            $choix_nettoyage  = '&Non', '&Oui'

            $this.nettoyage = [System.Convert]::ToBoolean($Host_method.UI.PromptForChoice($titre, $question, $choix_nettoyage, 0))
        }
        else{
            $this.nettoyage= $false
        }
    }
}


##################################
### PARTIE GESTION DE CREATION ###
##################################
### Nom de la fonction : CheckArbo
### Fonction de vérification de l'arborescence pour l'installation demandée
# paramètres en entrée : objet CInstallation
function CheckArbo($installation){
    write-host "Vérification de l'arborescence nécessaire à l'installation" -ForegroundColor DarkGreen -BackgroundColor White
    #pour une image en ligne
    if($installation.online){
        #vérification de l'existence du script forensic.sh
        if(-NOT(Test-Path $installation.chemin_script_forensic)){
            Write-Host $installation.chemin_script_forensic "est absent" -ForegroundColor DarkBlue -BackgroundColor Red
            write-host "!!!!!! FICHIER MANQUANT !!!!!!"  -ForegroundColor DarkBlue -BackgroundColor Red
            Write-Host 'Press any key to continue...';
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            exit
        }
        if(-NOT(Test-Path $installation.chemin_script_preseed)){
            Write-Host $installation.chemin_script_preseed "est absent" -ForegroundColor DarkBlue -BackgroundColor Red
            write-host "!!!!!! FICHIER MANQUANT !!!!!!"  -ForegroundColor DarkBlue -BackgroundColor Red
            Write-Host 'Press any key to continue...';
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            exit
        }
        if(-NOT(Test-Path $installation.chemin_script_ubuntu)){
            Write-Host $installation.chemin_script_ubuntu "est absent" -ForegroundColor DarkBlue -BackgroundColor Red
            write-host "!!!!!! FICHIER MANQUANT !!!!!!"  -ForegroundColor DarkBlue -BackgroundColor Red
            Write-Host 'Press any key to continue...';
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            exit
        }
        if(-NOT(Test-Path $installation.chemin_script_variables)){
            Write-Host $installation.chemin_script_variables "est absent" -ForegroundColor DarkBlue -BackgroundColor Red
            write-host "!!!!!! FICHIER MANQUANT !!!!!!"  -ForegroundColor DarkBlue -BackgroundColor Red
            Write-Host 'Press any key to continue...';
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            exit
        }
    }
    #pour une image hors ligne
    if(-not($installation.online)){
        $chemin_fichiers_exportes = $installation.chemin_base + "EXPORTATION\"

        #Configuration des fichiers à vérifier
        $fichiers_exportes = New-Object System.Collections.ArrayList
        $fichiers_exportes.AddRange(("Forensic-tools.zip","Logiciels-Windows.zip","Forensic*.ova"))

        foreach ($fichier in $fichiers_exportes){
            $chemin = $chemin_fichiers_exportes + $fichier
            if(-not(Test-Path $chemin)){
                Write-Host $chemin_fichiers_exportes$fichier "MANQUANT" -ForegroundColor DarkBlue -BackgroundColor Red
                write-host "!!!!!! FICHIERS MANQUANTS !!!!!!"  -ForegroundColor DarkBlue -BackgroundColor Red
                Write-Host 'Press any key to continue...';
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
                exit
            }
        }
    }
}

### Nom de la fonction : WindowsConfiguration
### Fonction de création des répertoires nécessaires et exclusion de Defender
function WindowsConfiguration($installation){
    #Désactivation de la restauration système
    Disable-ComputerRestore -Drive "c:\"
    
    #Création du répertoire Logiciels
    if(-not(Test-Path $installation.chemin_logiciels)){
        Write-Host "Création du répertoire hors-ligne de mise à jour Windows" -ForegroundColor DarkBlue -BackgroundColor White
        New-Item -ItemType Directory -Force -Path $installation.chemin_logiciels
    }

    #Création des dossiers de Forensic et paramétrage exclusion Defender
    Write-Host "Création des chemins du dossier Forensic" -ForegroundColor DarkBlue -BackgroundColor White
    New-Item -ItemType Directory -Force -Path $Chemin_forensic_tools
    New-Item -ItemType Directory -Force -Path $Chemin_forensic_dumps
    New-Item -ItemType Directory -Force -Path $Chemin_forensic_extract

    #Interdiction de l'exécution de programmes depuis le répertoire Extract
    $acl = Get-ACL -Path $Chemin_forensic_extract
        #Suppression de l'héritage et des permissions
    $acl.SetAccessRuleProtection($true,$false)
    $acl | Set-Acl -Path $Chemin_forensic_extract
        #Ajout de la règle de contrôle totale sur le dossier
    $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("Tout le monde","FullControl","ContainerInherit","None","Allow")
    $acl.SetAccessRule($accessrule)
    $acl |set-acl -Path $Chemin_forensic_extract
        #Ajout de la règle de LECTURE SEULE pour les fichiers dans le répertoire et ses sous-dossiers
    $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("Tout le monde","Read","ObjectInherit","None","Allow")
    $acl.AddAccessRule($accessrule)
    $acl |set-acl -Path $Chemin_forensic_extract

    #Exclusion du répertoire Extract de l'analyse de Windows Defender
    Write-Host "Création de l'exclusion "$Chemin_forensic_extract" dans DEFENDER" -foregroundcolor DarkBlue -backgroundcolor White
    Add-MpPreference -ExclusionPath $Chemin_forensic_extract
}

### Nom de la fonction : WindowsIsolationReseau
### Fonction de désactivation des protocoles ipv4 et ipv6 sur l'intégralité des cartes réseau
function WindowsIsolationReseau{
    Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
    Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip
}

### Nom de la fonction : Decompression
### Fonction de décompression des fichiers zip pour une installation hors-ligne
function Decompression($installation){
    #Paramétrage du dossier contenant l'exportation si l'installation est faite depuis un export précédent
    $dossier_exportation = Get-ChildItem -Recurse -Include 'EXPORTATION' -Path $installation.chemin_base |Select-Object Fullname
    if($dossier_exportation){
        $logiciels_zip_temp = $dossier_exportation.FullName + "\Logiciels-Windows.zip"
        $forensic_zip_temp = $dossier_exportation.FullName + "\Forensic-Tools.zip"

        #Décompression du zip contenant les logiciels Windows
        if(Test-Path $logiciels_zip_temp){
            Write-Host "Décompression du dépôt local Windows" -foregroundcolor DarkBlue -backgroundcolor White
            if(Test-Path $installation.chemin_logiciels){
                Remove-Item -Force -Recurse $installation.chemin_logiciels
            }
            Expand-Archive -Force -DestinationPath $installation.chemin_base $logiciels_zip_temp
        }

        #Décompression du zip contenant les logiciels Forensic
        if(Test-Path $forensic_zip_temp){
            Write-Host "Décompression du dépôt local Tools" -foregroundcolor DarkBlue -backgroundcolor White
            Remove-Item -Force -Recurse $Chemin_forensic_tools
            Expand-Archive -Force -DestinationPath $Chemin_forensic $forensic_zip_temp
        }
    }
}

################################
### PARTIE WINDOWS LOGICIELS ###
################################
### Nom de la fonction : 7z-Downloader
### Fonction de téléchargement et d'installation de 7zip
function 7z-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement 7-Zip (environ 1.7Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $7zip = $(@(Invoke-WebRequest -Uri $global:SOURCE_7Zip -UseBasicParsing).links.href) -match "64" -match 'msi$'
    $7zip_dl = $global:SOURCE_7Zip.split("/")[2] + "/" + $7zip[0]
    $7zip_version = $7zip_dl.Split("/")[-1]
    $7zip_sauvegarde = $installation.chemin_logiciels + $7zip_version
    Invoke-WebRequest -Uri $7zip_dl -UseBasicParsing -OutFile $7zip_sauvegarde
    Write-Host "Installation de 7-zip" -ForegroundColor DarkBlue -BackgroundColor White
    $arguments = '/I ' + $7zip_sauvegarde + ' /quiet'
    Start-Process -Wait msiexec.exe -ArgumentList $arguments
}

### Nom de la fonction : Aten-Downloader
### Fonction de téléchargement de Aten UC-232A
function Aten-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Aten-UC232A (environ 8Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $aten = $global:SOURCE_Aten
    $aten_version = $aten.split("/")[-1]
    $aten_sauvegarde = $Chemin_forensic_tools + $aten_version
    Invoke-WebRequest -Uri $aten -UseBasicParsing -OutFile $aten_sauvegarde
}

### Nom de la fonction : Balena-Downloader
### Fonction de téléchargement de Balena Etcher
function Balena-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Balena Etcher (environ 125Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $balena = $(@(Invoke-WebRequest -Uri $global:SOURCE_Balena -UseBasicParsing)).links.href -match "portable"
    $balena_dl = "https://github.com"+$balena[0]
    $balena_version = $balena.split("/")[-1]
    $balena_sauvegarde = $Chemin_forensic_tools + $balena_version
    Invoke-WebRequest -Uri $balena_dl -UseBasicParsing -OutFile $balena_sauvegarde
}

### Nom de la fonction : Brim-Downloader
### Fonction de téléchargement de Brim
function Brim-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Brim (environ 210Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $brim = Invoke-WebRequest -Uri $global:SOURCE_Brim -UseBasicParsing
    $brim_dl = ($brim.links.href -match '.exe$')[-1]
    $brim_version = $brim_dl.split("/")[-1]
    $brim_sauvegarde = $installation.chemin_logiciels + $brim_version
    Invoke-WebRequest -Uri $brim_dl -UseBasicParsing -OutFile $brim_sauvegarde
}

### Nom de la fonction : Chrome-Downloader
### Fonction de téléchargement de Chrome
function Chrome-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Chrome (environ 76Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $chrome_version = $global:SOURCE_Chrome.split("/")[-1]
    $chrome_sauvegarde = $installation.chemin_logiciels + $chrome_version
    Invoke-WebRequest -Uri $global:SOURCE_Chrome -UseBasicParsing -OutFile $chrome_sauvegarde
}

###Nom de la fonction : Comodo-Downloader
### Fonction de téléchargement de Comodo Rescue Disc
function Comodo-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Comodo (environ 51Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $comodo_niv1 = Invoke-WebRequest -Uri $global:SOURCE_Comodo -UseBasicParsing
    $comodo_dl = $comodo_niv1.links.href -match "iso"
    $comodo_version = $comodo_dl[0].split("/")[-1]
    $comodo_sauvegarde = $Chemin_forensic_tools + $comodo_version
    Invoke-WebRequest -Uri $comodo_dl[0]-UseBasicParsing -OutFile $comodo_sauvegarde
}

### Nom de la fonction : DBBrowser-Downloader
### Fonction de téléchargement de DB Browser for SQLite
function DBBrowser-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement DB Browser for SQLite (environ 17Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $dbbrowser = $(@(Invoke-WebRequest -Uri $global:SOURCE_DBBrowser -UseBasicParsing).links.href) -match 'msi$' -match "win64"
    $dbbrowser_dl = $dbbrowser[-1]
    $dbbrowser_version = $dbbrowser_dl.split("/")[-1]
    $dbbrowser_sauvegarde = $installation.chemin_logiciels + $dbbrowser_version
    Invoke-WebRequest -Uri $dbbrowser_dl -UseBasicParsing -OutFile $dbbrowser_sauvegarde
}

### Nom de la fonction : Debian-Downloader
### Fonction de téléchargement d'une Debian Live
function Debian-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Debian Live (1.2Go)" -ForegroundColor DarkBlue -BackgroundColor White
    $debian = $(@(Invoke-Webrequest -Uri $global:SOURCE_Debian -UseBasicParsing)).links.href -match "standard.iso"
    $debian_version = $debian[0]
    $debian_dl = $global:SOURCE_Debian + $debian_version
    $debian_sauvegarde = $Chemin_forensic_tools + $debian_version
    Invoke-WebRequest -Uri $debian_dl -UseBasicParsing -OutFile $debian_sauvegarde
}

### Nom de la fonction : dotPeek-Downloader
### Fonction de téléchargement de dotPeek
function dotPeek-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement .Peek (75Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $dotpeek_niv1 = $(@(Invoke-WebRequest -Uri $global:SOURCE_dotPeek -UseBasicParsing).links.href) -match "windows64"
    $dotpeek_niv2 = "https:" + $dotpeek_niv1
    $dotpeek_sauvegarde = $Chemin_forensic_tools + "dotPeek.exe"
    Invoke-WebRequest -Uri $dotpeek_niv2 -UseBasicParsing -OutFile $dotpeek_sauvegarde

}

### Nom de la fonction : Eset-Downloader
### Fonction de téléchargement de Eset Live Antivirus
function Eset-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Eset Live Antivirus (environ 750Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $eset_version = $global:SOURCE_Eset.Split("/")[-1]
    $eset_sauvegarde = $Chemin_forensic_tools + $eset_version
    Invoke-WebRequest -Uri $global:SOURCE_Eset -UseBasicParsing -OutFile $eset_sauvegarde
}

### Nom de la fonction : EZTools-Downloader
### Fonction de téléchargement des outils d'Eric Zimmerman
function EZTools-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement des outils d'Eric Zimmerman" -ForegroundColor DarkBlue -BackgroundColor White
    $tools_zimmerman = $Chemin_forensic_tools + "EZ_tools\"
    New-Item -ItemType Directory -Force -Path $tools_zimmerman
    $EZ_tools_ps1 = ".\" + $global:SOURCE_EZTools.split("/")[-1]
    Invoke-WebRequest -Uri $global:SOURCE_EZTools -UseBasicParsing -Outfile $EZ_tools_ps1
    $arguments = $EZ_tools_ps1 + " -Dest " + $tools_zimmerman
    Start-Process -NoNewWindow -Wait powershell.exe -ArgumentList $arguments
    Remove-Item -Force $EZ_tools_ps1
}

### Nom de la fonction : Firefox-Downloader
### Fonction de téléchargement de Firefox
function Firefox-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Firefox (environ 55Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $firefox_sauvegarde = $installation.chemin_logiciels + "Firefox.exe"
    Invoke-WebRequest -Uri $global:SOURCE_Firefox -UseBasicParsing -OutFile $firefox_sauvegarde
}

### Nom de la fonction : Foxit-Downloader
### Fonction de téléchargement de Foxit (PDF Reader)
function Foxit-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Foxit Reader (environ 182Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    Write-Host "ATTENTION TELECHARGEMENT RELATIVEMENT LONG (+ de 5 minutes), PATIENCE !!" -ForegroundColor White -BackgroundColor DarkBlue
    $foxit_sauvegarde = $installation.chemin_logiciels + "Foxit.exe"
    Invoke-WebRequest -Uri $global:SOURCE_Foxit -UseBasicParsing -Outfile $foxit_sauvegarde
}

### Nom de la fonction : HexEditor-Downloader
### Fonction de téléchargement de Hex Editor
function HexEditor-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Hex Editor (environ 15Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $hexeditor_dl = $global:SOURCE_HexEditor
    $hexeditor_version = $hexeditor_dl.Split("/")[-1]
    $hexeditor_sauvegarde = $installation.chemin_logiciels + $hexeditor_version
    Invoke-WebRequest -Uri $hexeditor_dl -UseBasicParsing -OutFile $hexeditor_sauvegarde
}

### Nom de la fonction : KavRescue-Downloader
### Fonction de téléchargement de KavRescue
function KavRescue-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement de Kavrescue (650Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $kavrescue = $(@(Invoke-WebRequest -Uri $global:SOURCE_Kavrescue -UseBasicParsing).links.href) -match 'iso$'
    $kavrescue_dl = $kavrescue[0]
    $kavrescue_sauvegarde = $Chemin_forensic_tools + $kavrescue_dl.split("/")[-1]
    Invoke-WebRequest -Uri $kavrescue_dl -UseBasicParsing -OutFile $kavrescue_sauvegarde
}

### Nom de la fonction : LibreOffice-Downloader
### Fonction de téléchargement de LibreOffice
function LibreOffice-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement LibreOffice (environ 322Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $libreoffice_niv1 = $(@(Invoke-WebRequest -Uri $global:SOURCE_LibreOffice -UseBasicParsing).links.href) -match '[0-9].[0-9].[0-9]'
    $libreoffice_niv2 = $global:SOURCE_LibreOffice + $libreoffice_niv1[-1] + "win/x86_64/"
    $libreoffice_version = $(@(Invoke-WebRequest -Uri $libreoffice_niv2 -UseBasicParsing).links.href) -match 'x64.msi$'
    $libreoffice_version = $libreoffice_version[0]
    $libreoffice_dl = $libreoffice_niv2 + $libreoffice_version
    $libreoffice_sauvegarde = $installation.chemin_logiciels + $libreoffice_version
    Invoke-WebRequest -Uri $libreoffice_dl -UseBasicParsing -OutFile $libreoffice_sauvegarde
}

### Nom de la fonction : MRC-Downloader
### Fonction de téléchargement de Magnet RAM Capture
function MRC-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Magnet RAM Capture (moins d'1Mo)" -ForegroundColor DarkBlue -BackgroundColor White
   #$magnet_version = $global:SOURCE_Magnet.split("/")[-1]
    $magnet_version = "MRCv120.exe"
    $magnet_sauvegarde = $Chemin_forensic_tools + $magnet_version
    Invoke-WebRequest -Uri $global:SOURCE_Magnet -UseBasicParsing -Outfile $magnet_sauvegarde
}

### Nom de la fonction : NetworkMiner-Downloader
### Fonction de téléchargement de Network Miner
function NetworkMiner-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement NetworkMiner (2.5Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $networkminer_sauvegarde = $Chemin_forensic_tools + "networkminer.zip"
    Invoke-WebRequest -Uri $global:SOURCE_NetworkMiner -UseBasicParsing -OutFile $networkminer_sauvegarde
}

### Nom de la fonction : Notepad-Downloader
### Fonction de téléchargement de Notepad++
function Notepad-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Notepad++ (environ 4Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $notepad_niv1 = $(@(Invoke-WebRequest -Uri $global:SOURCE_Notepad -UseBasicParsing).links.href) -match "downloads"
    $notepad_niv1 = $global:SOURCE_Notepad + $notepad_niv1[0].split("/")[-2]
    $notepad_niv2 = $(@(Invoke-WebRequest -Uri $notepad_niv1 -UseBasicParsing).links.href) -match 'exe$' -match "64"
    $notepad_dl = $notepad_niv2[0]
    $notepad_version = $notepad_dl.split("/")[-1]
    $notepad_sauvegarde = $installation.chemin_logiciels + $notepad_version
    Invoke-WebRequest -Uri $notepad_dl -UseBasicParsing -OutFile $notepad_sauvegarde
}

### Nom de la fonction : Npcap-Downloader
### Fonction de téléchargement de NPCap
function Npcap-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Npcap (moins de 1Mo)" -foregroundcolor DarkBlue -backgroundcolor White
    $npcap = $(@(Invoke-WebRequest -Uri $global:SOURCE_NPCap -UseBasicParsing).links.href -match 'npcap' -match 'exe$' -notmatch "nmap")
    $npcap_version = $npcap[-1]
    $npcap_dl = $global:SOURCE_NPCap + $npcap_version
    $npcap_sauvegarde = $installation.chemin_logiciels + $npcap_version
    Invoke-WebRequest -Uri $npcap_dl -UseBasicParsing -OutFile $npcap_sauvegarde
}

### Nom de la fonction : Plaso-Downloader
### Fonction de téléchargement de Plaso for Windows
function Plaso-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement de Plaso for Windows (43Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $log2timeline_sauvegarde = $Chemin_forensic_tools + $global:SOURCE_Plaso.split("/")[-1]
    Invoke-WebRequest -Uri $global:SOURCE_Plaso -UseBasicParsing -OutFile $log2timeline_sauvegarde
}

### Nom de la fonction : Putty-Downloader
### Fonction de téléchargement de Putty
function Putty-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Putty (environ 3Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $putty = $(@(Invoke-WebRequest -Uri $global:SOURCE_Putty -UseBasicParsing).links.href) -match 'msi$' -match "64bit"
    $putty_dl = $putty[0]
    $putty_version = $putty_dl.split("/")[-1]
    $putty_sauvegarde = $installation.chemin_logiciels + $putty_version
    Invoke-WebRequest -Uri $putty_dl -UseBasicParsing -OutFile $putty_sauvegarde
}

### Nom de la fonction : Python-Downloader
### Fonction de téléchargement de Python
function Python-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Python (environ 28Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $python = $(@(Invoke-WebRequest -Uri $global:SOURCE_Python -UseBasicParsing).links.href) -match 'exe$' -match "64"
    $python_dl = $python[0]
    $python_version = $python_dl.Split("/")[-1]
    $python_sauvegarde = $installation.chemin_logiciels + $python_version
    Invoke-WebRequest -Uri $python_dl -UseBasicParsing -OutFile $python_sauvegarde
}

### Nom de la fonction : Rufus-Downloader
### Fonction de téléchargement de Rufus
function Rufus-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Rufus (1.1Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $rufus = $(@(Invoke-WebRequest -Uri $Global:SOURCE_Rufus -UseBasicParsing).links.href) -match 'p.exe'
    $rufus_dl = $rufus[0]
    $rufus_sauvegarde = $Chemin_forensic_tools + $rufus_dl.split("/")[-1]
    Invoke-WebRequest -Uri $rufus_dl -UseBasicParsing -Outfile $rufus_sauvegarde
}

### Nom de la fonction : StarTech-Downloader
### Fonction de téléchargement des drivers StarTech.com USB2106S
function StarTech-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement des drivers StarTech USB2106S (environ 33Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $startech_sauvegarde = $Chemin_forensic_tools + "startech_USB2106S.zip"
    Invoke-WebRequest -Uri $global:SOURCE_Startech -UseBasicParsing -OutFile $startech_sauvegarde
}

### Nom de la fonction : TestDisk-Downloader
### Fonction de téléchargement de Test Disk et PhotoRec
function TestDisk-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement TestDisk/Photorec pour Windows (environ 25Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $testdisk = Invoke-WebRequest -Uri $global:SOURCE_TestDisk -UseBasicParsing
    $testdisk = @($testdisk.links.href |Select-String "win64.zip" |sort -Unique -Descending)[0]
    $testdisk_dl = $testdisk.Line -replace "Download_and_donate.php/"
    #Paramétrage du nom de fichier local téléchargé
    $testdisk_version = $testdisk_dl.split("/")[-1]
    $testdisk_sauvegarde = $Chemin_forensic_tools + $testdisk_version
    Invoke-WebRequest -Uri $testdisk_dl -UseBasicParsing -Outfile $testdisk_sauvegarde
}

### Nom de la fonction : TZworks-Downloader
### Fonction de téléchargement de TZworks (pour windows 64bits)
### !!!!!! CECI NE TELECHARGE PAS LA LICENCE !!!!!!
function TZWorks-Downloader{
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement TZworks pour Windows (environ 98Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    Write-Host "ATTENTION !!! Ceci télécharge la suite TZWORKS mais PAS LE FICHIER DE LICENCE !!" -ForegroundColor Black -BackgroundColor White
    $tzworks_niv1 = Invoke-Webrequest -Uri $global:SOURCE_TZworks -UseBasicParsing
    #Récupération du lien de téléchargement de la suite complète pour Windows
    $tzworks_niv2 = $tzworks_niv1.Links.href | Select-String "vers=win" | Select-String "typ=64" | Select-String "proto_id=32" | Out-String
    $tzworks_niv2_lien = $tzworks_niv2.split("\'")[1]
    $tzworks_niv2_lien = $tzworks_niv2_lien.Replace("&amp;","&")
    #Récupération du lien de téléchargement de la suite complète pour Windows sur la page intermédiaire de User AGREEMENT
    $tzworks_niv3 = Invoke-WebRequest -Uri $tzworks_niv2_lien -UseBasicParsing
    $tzworks_niv3_lien = $tzworks_niv3.Content.Split("\'")[1] 
    $tzworks_sauvegarde = $Chemin_forensic_tools + "TZWorks_" +$tzworks_niv3_lien.split("/")[5]
    Invoke-WebRequest -Uri $tzworks_niv3_lien -UseBasicParsing -OutFile $tzworks_sauvegarde
}

### Nom de la fonction : VirtualBox-Downloader
### Fonction de téléchargement et d'installation de VirtualBox
function VirtualBox-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement VirtualBox (environ 103Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $virtualbox = $(@(Invoke-WebRequest -Uri $global:SOURCE_VirtualBox -UseBasicParsing).links.href) -match 'exe$'
    $virtualbox_dl = $virtualbox[0]
    $virtualbox_version = $virtualbox.split("/")[-1]
    $virtualbox_sauvegarde = $installation.chemin_logiciels + $virtualbox_version
    Invoke-WebRequest -Uri $virtualbox_dl -UseBasicParsing -Outfile $virtualbox_sauvegarde
    Write-Host "Installation de VirtualBox" -ForegroundColor DarkBlue -BackgroundColor White
    $arguments = "--silent --ignore-reboot"
    Start-Process -Wait $virtualbox_sauvegarde -ArgumentList $arguments
    $env:Path += ";C:\Program Files\Oracle\VirtualBox"
}

### Nom de la fonction : VBoxExtPack-Downloader
### Fonction de téléchargement et d'installation du pack extension de VirtualBox
function VBoxExtPack-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement VirtualBox Extension Pack (environ 11Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $virtualbox_extpack = $(@(Invoke-WebRequest -Uri $global:SOURCE_VirtualBoxExtPack -UseBasicParsing).links.href) -match "extpack"
    $virtualbox_extpack_dl = $virtualbox_extpack[0]
    $virtualbox_extpack_version = $virtualbox_extpack.split("/")[-1]
    $virtualbox_extpack_sauvegarde = $installation.chemin_logiciels + $virtualbox_extpack_version
    Invoke-WebRequest -Uri $virtualbox_extpack_dl -UseBasicParsing -Outfile $virtualbox_extpack_sauvegarde
    Write-Host "Installation de l'extension pack de VirtualBox" -ForegroundColor DarkBlue -BackgroundColor White
    echo y | & $global:VIRTUALBOX extpack install --replace $virtualbox_extpack_sauvegarde
}

### Nom de la fonction : VLC-Downloader
### Fonction de téléchargement de VLC
function VLC-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement VLC (environ 54Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $vlc_niv1 = $(@(Invoke-WebRequest -Uri $global:SOURCE_VLC -UseBasicParsing).links.href) -match '[0-9].[0-9].[0-9]'
    $vlc_niv2 = $global:SOURCE_VLC + $vlc_niv1[-1] + "win64/"
    $vlc_version = $(@(Invoke-WebRequest -Uri $vlc_niv2 -UseBasicParsing).links.href) -match 'msi$'
    $vlc_dl = $vlc_niv2 + $vlc_version
    $vlc_sauvegarde = $installation.chemin_logiciels + $vlc_version
    Invoke-WebRequest -Uri $vlc_dl -UseBasicParsing -OutFile $vlc_sauvegarde
}

### Nom de la fonction : WinDefender-Downloader
### Fonction de téléchargement de la mise à jour de Windows Defender
function WinDefender-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement de la mise à jour de Windows Defender" -foregroundcolor DarkBlue -backgroundcolor White
    $defender_sauvegarde = $installation.chemin_logiciels + "Windows-defender-update.exe"
    Invoke-WebRequest -Uri $global:SOURCE_WindowsDefender -OutFile $defender_sauvegarde
}

### Nom de la fonction : Winscp-Downloader
### Fonction de téléchargement de Winscp
function Winscp-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement WinSCP (environ 12Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    [uri]$source = $global:SOURCE_Winscp
    $winscp_niv1 = Invoke-WebRequest -Uri $source.OriginalString -UseBasicParsing
    $lien_relatif = $($winscp_niv1.Links.href -match "exe")[0]
    $lien_uri = $source.Scheme+"://"+$source.Authority+$lien_relatif
    $winscp_niv2 = Invoke-WebRequest -Uri $lien_uri -UseBasicParsing
    $winscp_dl =($winscp_niv2.Links.href -match "\.exe")[0]
    $winscp_version = $winscp_dl.Split("/")[-1]
    $winscp_sauvegarde = $installation.chemin_logiciels + $winscp_version
    Invoke-WebRequest -Uri $winscp_dl -UseBasicParsing -OutFile $winscp_sauvegarde
}

### Nom de la fonction : Wireshark-Downloader
### Fonction de téléchargement de Wireshark
function Wireshark-Downloader($installation){
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Wireshark (environ 59Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $wireshark = $(@(invoke-Webrequest -Uri $global:SOURCE_Wireshark -UseBasicParsing).links.href) -match "exe" -match "win64"
    $wireshark_dl = $wireshark[0]
    $wireshark_version = $wireshark_dl.split("/")[-1]
    $wireshark_sauvegarde = $installation.chemin_logiciels + $wireshark_version
    Invoke-WebRequest -Uri $wireshark_dl -UseBasicParsing -OutFile $wireshark_sauvegarde
}

### Nom de la fonction : WindowsOnlineToolsDownloader
### Fonction de téléchargement des logiciels Windows en ligne
function WindowsOnlineToolsDownloader($installation){
# VERS LE DOSSIER LOGICIELS_WINDOWS
    #Récupération ET INSTALLATION de 7-zip
    7z-Downloader($installation)

    #Récupération de Brim
    Brim-Downloader($installation)

    #Récupération de Chrome
    Chrome-Downloader($installation)

    #Récupération de DB Browser for SQLite
    DBBrowser-Downloader($installation)

    #Récupération de Firefox
    Firefox-Downloader($installation)

    #Récupération de Foxit Reader
    Foxit-Downloader($installation)

    #Récupération de Hex Editor
    HexEditor-Downloader($installation)

    #Récupération de LibreOffice
    LibreOffice-Downloader($installation)

    #Récupération de Notepad++
    Notepad-Downloader($installation)

    #Récupération de NPCAP afin de pouvoir créer des captures réseau live
    Npcap-Downloader($installation)

    #Récupération de Putty
    Putty-Downloader($installation)

    #Récupération de Python
    Python-Downloader($installation)

    #Récupération de VirtualBox
    VirtualBox-Downloader($installation)

    #Récupération de VirtualBox Extension Pack
    VBoxExtPack-Downloader($installation)

    #Récupération de VLC
    VLC-Downloader($installation)

    #Récupération de Winscp
    Winscp-Downloader($installation)

    #Récupération de Wireshark
    Wireshark-Downloader($installation)

#VERS LE DOSSIER TOOLS
    #Récupération de Aten UC-232A
    Aten-Downloader

    #Récupération de Balena-Etcher
    Balena-Downloader

    #Récupération de Comodo
    Comodo-Downloader

    #Récupération de Debian Live
    Debian-Downloader

    #Récupération de dotPeek
    dotPeek-Downloader

    #Récupération de Eset
    Eset-Downloader

    #Récupération Eric Zimmerman Tools
    EZTools-Downloader

    #Récupération de Kavrescue
    #(SUITE AU CONTEXTE ACTUEL, LE TELECHARGEMENT DE KavRescue EST SUSPENDU)
#    KavRescue-Downloader

    #Récupération de Magnet RAM Capture
    MRC-Downloader

    #Récupération de NetworkMiner
    NetworkMiner-Downloader

    #Récupération de Plaso pour Windows 64bit
    Plaso-Downloader

    #Récupération de Rufus
    Rufus-Downloader

    #Récupération des drivers StarTech.com USB2106S
    StarTech-Downloader

    #Récupération de Testdisk et Photorec pour Windows
    TestDisk-Downloader

    #Récupération de TZWorks pour Windows 64bits
    TZWorks-Downloader

    #Si export, récupération de la mise à jour de Defender
    if($installation.export){
        #Récupération de la mise à jour de Defender
        WinDefender-Downloader($installation)
    }
}

### Nom de la fonction WindowsOfflineToolsInstaller
### Fonction d'installation des logiciels Windows hors ligne
function WindowsOfflineToolsInstaller($installation){
    #Installation des logiciels Windows MSI
    $logiciels_msi = Get-ChildItem -Recurse -Path $installation.chemin_logiciels -Include *.msi | select FullName
    Foreach ($logiciel in $logiciels_msi){
        if($logiciel.FullName -match "DB.Browser"){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = '/I '+ $logiciel.FullName +' SHORTCUT_SQLITE_PROGRAMMENU=1 SHORTCUT_SQLCIPHER_PROGRAMMENU=1 SHORTCUT_SQLITE_DESKTOP=1 SHORTCUT_SQLCIPHER_DESKTOP=1 /quiet'
            Start-Process -Wait msiexec.exe -ArgumentList $arguments
        }
        if($logiciel.FullName -match "LibreOffice"){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = '/I ' + $logiciel.FullName + ' /norestart /qn'
            Start-Process -Wait msiexec.exe -ArgumentList $arguments
        }
        else{
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = '/I ' + $logiciel.FullName + ' /quiet'
            Start-Process -Wait msiexec.exe -ArgumentList $arguments
        }
    }

    #Installation des logiciels Windows MSIXBUNDLE
    $logiciels_msixbundle = Get-ChildItem -Recurse -Path $installation.chemin_logiciels -Include *.msixbundle | select FullName
    Foreach ($logiciel in $logiciels_msixbundle){
        Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
        & Add-AppxPackage -Path $logiciel.FullName -ErrorAction SilentlyContinue
    }

    #Installation des logiciels Windows EXE
    $logiciels_exe = Get-ChildItem -Recurse -Path $installation.chemin_logiciels -Include *.exe | select FullName
    Foreach ($logiciel in $logiciels_exe){
        if($logiciel.FullName -match 'AcroRdrDC'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = "/sAll /rs /msi EULA_ACCEPT=YES"
            Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
        }

        if($logiciel.FullName -match 'Brim'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            Start-Process $logiciel.FullName
             #Attente du lancement de l'installation
            Sleep 6

            #Validation de EULA
            $wshell = New-Object -ComObject wscript.shell;
            $wshell.AppActivate('Installation de Brim')
            Sleep 1
            $wshell.SendKeys('~')

            #Arrêt de Brim automatiquement lancé après installation
            While(!$brim){
	            $brim = Get-Process brim -ErrorAction SilentlyContinue
            }
            Stop-Process -Name Brim
        }

        if($logiciel.FullName -match 'Firefox'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = "-ms"
            Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
        }

        if($logiciel.FullName -match 'Foxit'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = "/VERYSILENT /NORESTART"
            Start-Process -Wait $logiciel.FullName -ArgumentList $arguments            
        }

        if($logiciel.FullName -match 'hex-editor'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = "-silent"
            Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
        }

        if($logiciel.FullName -match 'npp'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = "/S"
            Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
        }

        if($logiciel.FullName -match 'npcap'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            Write-Host "ATTENTION VOUS DEVREZ AUTORISER L'INSTALLATION" -ForegroundColor DarkBlue -BackgroundColor Green
            Start-Process -Wait $logiciel.FullName
        }

        if($logiciel.FullName -match 'python'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = "/quiet InstallAllUsers=1 PrependPath=1"
            Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
        }

        if($logiciel.FullName -match 'VirtualBox'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = "--silent --ignore-reboot"
            Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
            $env:Path += ";C:\Program Files\Oracle\VirtualBox"
        }

        if($logiciel.FullName -match 'Windows-Defender'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            Start-Process -Wait $logiciel.Fullname
        }

        if($logiciel.FullName -match 'Winscp'){
            Write-Host "Installation de "$logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = "/silent /allusers /norestart"
            Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
        }

        if($logiciel.FullName -match 'Wireshark'){
            Write-Host "Installation de " $logiciel.FullName -ForegroundColor DarkBlue -BackgroundColor White
            $arguments = "/S"
            Start-Process -Wait $logiciel.FullName -ArgumentList $arguments
        }
    }
}

################################
### PARTIE WINDOWS NETTOYAGE ###
################################
### Nom de la fonction : WindowsCreationRestauration
### Fonction permettant la création d'un point de restauration en vue d'un nettoyage
function WindowsCreationRestauration{
    #Suppression des points de restauration existants
    vssadmin delete shadows /all /quiet
    #Activation de la restauration
    Enable-ComputerRestore -Drive "c:\"
    #Création du point de restauration
    Checkpoint-Computer -Description "Pré-installation" -RestorePointType "MODIFY_SETTINGS"
    #Désactivation de la restauration
    Disable-ComputerRestore -Drive "c:\"
}

### Nom de la fonction : WindowsNettoyage
### Fonction permettant la remise en configuration du PC en cas de demande de nettoyage
function WindowsNettoyage($installation){
    #Suppression des dossiers créés
    Write-Host "Suppression du dossier " $Chemin_forensic -foregroundcolor DarkBlue -backgroundcolor White
    Remove-Item -Recurse -Force $Chemin_forensic
    
    #suppression des executables recopiés
    Write-Host "Suppression des exécutables pour Windows" -foregroundcolor DarkBlue -backgroundcolor White
    Remove-Item -Force -Recurse -Path $installation.chemin_logiciels

    #suppression du répertoire VirtualBox créé
    Write-Host "Suppression du répertoire VirtualBox créé" -foregroundcolor DarkBlue -backgroundcolor White
    Remove-Item -Force -Recurse -Path $installation.chemin_repertoire_VM

    #Restauration du système (créé dans la fonction Windows-CreationRestauration)
    Disable-ComputerRestore -Drive "c:\"
    $point_de_restauration = Get-ComputerRestorePoint
    Write-Host "ETES VOUS SÛR DE VOULOIR REMETTRE L'ORDINATEUR EN CONFIGURATION INITIALE ?" -ForegroundColor Yellow -BackgroundColor Red
    Restore-Computer -RestorePoint $point_de_restauration.SequenceNumber -Confirm
}

###Nom de la fonction : Exportation
### Fonction d'exportation du répertoire _Tools, des exécutables Windows et de la SIFT pour importation sur un PC offline
function Exportation($installation){
    New-Item -ItemType Directory -Force -Path $installation.chemin_export
    $date_export = Get-Date -Format "yyyy-MM-dd"

    #Compression des logiciels windows dans l'archive Logiciels-Windows.zip
    Write-Host "Compression logiciels Windows" -ForegroundColor DarkBlue -BackgroundColor White
    $zip_logicielswindows = $installation.chemin_export + "Logiciels-Windows.zip"
    Compress-Archive -Path $installation.chemin_logiciels -DestinationPath $zip_logicielswindows

    #Compression des Tools récupérés dans l'archive "Forensic-Tools.zip"
    Write-Host "Compression du dossier Tools" -ForegroundColor DarkBlue -BackgroundColor White
    $chemin_fichier_zip = $installation.chemin_export + $global:TYPE_FORENSIC + "-Tools.zip"
    Compress-Archive -Path $Chemin_forensic_tools -DestinationPath $chemin_fichier_zip

    #Déplacement de la machine virtuelle
    Write-Host "Déplacement de la machine virtuelle" -ForegroundColor DarkBlue -BackgroundColor White
    $destination_ova = $installation.chemin_export + $installation.nom_ova
    Move-Item -Path $installation.chemin_ova -Destination $destination_ova

    #Compression des fichiers récupérés (tar, zip et ps1) dans une unique archive
    Write-Host "Compression vers EXPORTATION.zip" -ForegroundColor DarkBlue -BackgroundColor White
        #paramétrage du nom de fichier de sortie
    $nom_fichier_export = $installation.chemin_base + 'EXPORTATION-' + $global:TYPE_FORENSIC + $date_export + '.zip'
        #paramétrage des arguments à passer à 7z pour la création de l'archive
    $arguments = 'a ' + $nom_fichier_export + ' -tzip '+$installation.chemin_export+' '+$installation.chemin_base+'Setup.bat '+$installation.chemin_base+'installer.ps1 ' +$installation.chemin_script
        #Création de l'archive
    Start-Process -Wait 'C:\Program Files\7-zip\7z.exe' -ArgumentList $arguments
        #Suppression du dossier d'exportation
    Remove-Item -Force -Recurse $installation.chemin_export
}

################
# PARTIE LINUX #
################
### Nom de la fonction : LinuxViergeImport
### Fonction de création de la machine virtuelle dans VirtualBox via packer
function LinuxCreation($installation){
    #Récupération ET DECOMPRESSION de Packer
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement et décompression Packer (environ 28Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $packer = $(@(Invoke-WebRequest -Uri $global:SOURCE_Packer -UseBasicParsing).links.href) -match "windows" -match "64"
    $packer_dl = $packer[0]
    $packer_version = $packer_dl.split("/")[-1]
    $packer_sauvegarde = $installation.chemin_script + $packer_version
    Invoke-WebRequest -Uri $packer_dl -UseBasicParsing -OutFile $packer_sauvegarde
    Expand-Archive -Force -DestinationPath $installation.chemin_script $packer_sauvegarde
    Remove-Item -Force $packer_sauvegarde

    #Récupération de Ubuntu
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Téléchargement Ubuntu Mini Iso (environ 80Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $ubuntu_source = "http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/current/legacy-images/netboot/"
    $ubuntu = $(@(Invoke-Webrequest -Uri $ubuntu_source -UseBasicParsing).links.href) -match 'iso$'
    $ubuntu_dl = $ubuntu_source + $ubuntu[0]
    $ubuntu_version = $ubuntu[0]
    $ubuntu_sauvegarde = $installation.chemin_script + $ubuntu_version
    Invoke-WebRequest -Uri $ubuntu_dl -UseBasicParsing -OutFile $ubuntu_sauvegarde

    #Configuration du fichier variables.json pour l'export et la conservation de la VM
    $fichier_variables = $installation.chemin_script + "variables.json"

    #Exportation
    if($installation.export){
        (Get-Content -Path $fichier_variables) |
        ForEach-Object {$_ -Replace 'skip_export": "true', 'skip_export": "false'} |
            Set-Content -Path $fichier_variables
    }
    #Sans Exportation
    if(-not ($installation.export)){
        (Get-Content -Path $fichier_variables) |
        ForEach-Object {$_ -Replace 'skip_export": "false', 'skip_export": "true'} |
            Set-Content -Path $fichier_variables
    }

    #Machine virtuelle à ne pas conserver
    if($installation.nettoyage){
        (Get-Content -Path $fichier_variables) |
        ForEach-Object {$_ -Replace 'keep_registered": "true', 'keep_registered": "false'} |
            Set-Content -Path $fichier_variables
    }
    #Machine virtuelle à conserver
    if(-not ($installation.nettoyage)){
        (Get-Content -Path $fichier_variables) |
        ForEach-Object {$_ -Replace 'keep_registered": "false', 'keep_registered": "true'} |
            Set-Content -Path $fichier_variables
    }

    #Nommage de la machine virtuelle
    $regex = '"name": "' + $global:NOM_BASE_VM +'_\d\d\d\d-\d\d-\d\d"'
    $remplacement = '"name": "' + $installation.nom_VM + '"'
    (Get-Content -Path $fichier_variables) -replace $regex, $remplacement |Set-Content $fichier_variables

    #Adresse IP du PC Hôte (devenu obligatoire suite à un pb avec VBox 7.0)
    $regex = '"host_ip": "\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}"'
    $remplacement = '"host_ip": "' + $installation.ipaddress + '"'
    (Get-Content -Path $fichier_variables) -replace $regex, $remplacement |Set-Content $fichier_variables

    #Lancement de la creation de la machine via Packer
    $chemin_origine = Get-Location
    Set-Location -Path $installation.chemin_script
    $packer = $installation.chemin_script + "packer.exe"
    $arguments = " build -on-error=ask -var-file=" + $installation.chemin_script + "variables.json " + $installation.chemin_script + "ubuntu.json"
    Start-Process -NoNewWindow -Wait -FilePath $packer -ArgumentList $arguments
    Set-Location -Path $chemin_origine

    #Suppression de l'iso Linux
    Get-ChildItem $installation.chemin_script -Include *.iso -Recurse | Remove-Item

    #Suppression de l'exécutable packer
    Get-ChildItem $installation.chemin_script -Include *.exe -Recurse | Remove-Item

    #Création du répertoire partagé si besoin
    if(-not ($installation.nettoyage)){
        LinuxPartage
    }

    #Suppression des vestiges de Packer
    $chemin_packer_cache = $installation.chemin_script + "packer_cache\"
    Remove-Item -Force -Recurse $chemin_packer_cache
}

### Nom de la fonction : LinuxCompletImport
### Fonction réalisant l'import d'une machine WSL exportée précédemment
function LinuxOvaImport($installation){
    $ova = Get-ChildItem -Recurse -Path $installation.chemin_base -Include *.ova | select FullName
    $parameter = "import " + $ova[0].FullName
    Start-Process -NoNewWindow -Wait -FilePath $global:VIRTUALBOX -ArgumentList $parameter

    #Création du répertoire partagé
    LinuxPartage
}

### Nom de la fonction : LinuxPartage
### Fonction réalisant la mise en place du dossier partagé
function LinuxPartage(){
    #Récupération de l'ID de la VM Forensic
    start-Process -NoNewWindow -Wait -FilePath $global:VIRTUALBOX -ArgumentList "list vms" -RedirectStandardOutput "vmlistSource.txt"

    #Création de l'expression régulière
    $regex = '"'+$global:NOM_BASE_VM +'_\d\d\d\d-\d\d-\d\d"'

    #Récupération des VM existantes dans VirtualBox correspondantes à l'expression régulière
    $vm = $(Get-Content "vmlistSource.txt")
    
    #Si une VM existe dans VirtualBox
    if($vm){

        #Si une seule VM existe dans VirtualBox
        if ($vm.gettype().Name -eq "String"){
            #Si la machine correspond à l'expression régulière, on garde le nom
            if($vm -match $regex){
                $vm_en_cours = $vm
            }
            #sinon on prévoit une valeur $null
            else{
                $vm_en_cours = $null
            }
        }
        #Si VirtualBox contient plusieurs VM
        else{
            #On récupère toutes les VM correspondant à l'expression régulière
            $vm_temp = ($vm -match $regex)

            #Si aucune VM ne correspondait, on prévoit une valeur $null
            if(-not($vm_temp)){
                $vm_en_cours = $null
            }
            #Sinon on ne conserve que la dernière VM dans la liste
            else{
                $vm_en_cours = $vm_temp[-1]
            }
        }

        #Si une machine Forensic a été trouvé, création du partage
        if($vm_en_cours){
            #Récupération de l'ID de la VM
            $vm_id = $vm_en_cours.split(" ")[-1]
            $vm_id = $vm_id.Replace("{","").Replace("}","")

            #Mise en place du partage
            $Name = "Forensic"
            $parameter = "sharedfolder add " + $vm_id + " --name " + $Name + " --hostpath " + $Chemin_forensic + " --automount"
            Start-Process -NoNewWindow -Wait -FilePath $global:VIRTUALBOX -ArgumentList $parameter
        }
    }

    #Suppression du fichier temporaire
    Remove-Item -Force "vmlistSource.txt"
}

################################################################################
########################## FONCTION PRINCIPALE #################################
################################################################################
#Passage en mode administrateur
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::"Administrator")) {
    $Arguments = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -Verb RunAS -ArgumentList $arguments
    exit
}

#Configuration du chemin relatif
$chemin_base = $MyInvocation.MyCommand.Definition
$chemin_base = Split-Path $chemin_base
Set-Location -Path $chemin_base

#Création de l'objet contenant les paramètres d'installation
$installation = New-Object CInstallation($chemin_base)

#Vérification de la présence des fichiers nécessaires
CheckArbo($installation)

#Configuration des répertoires et exclusion de Defender
WindowsConfiguration($installation)

#Mise en place de la restauration
if($installation.nettoyage){
    WindowsCreationRestauration
}

#Déroulé de l'installation EN ligne
if($installation.online){
    #Téléchargement des logiciels Windows
    WindowsOnlineToolsDownloader($installation)

    if (-not($installation.nettoyage)){
        #Installation des logiciels Windows
        WindowsOfflineToolsInstaller($installation)
    }                

    #Creation de la machine Linux
    LinuxCreation($installation)
}
#Déroulé de l'installation HORS ligne
else{
    #Décompression des fichiers zip
    Decompression($installation)

    #Installation des logiciels Windows
    WindowsOfflineToolsInstaller($installation)

    #Importation de la machine Linux
    LinuxOvaImport($installation)
}

#Exportation des éléments installés
if($installation.export){
    Exportation($installation)
}

#Nettoyage et remise en état d'origine du PC
if($installation.nettoyage){
    WindowsNettoyage($installation)
}
#Sinon isolation réseau du PC
else{
#    WindowsIsolationReseau
}

Write-Host 'INSTALLATION TERMINEE...' -ForegroundColor White -BackgroundColor Green
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
Write-Host -NoNewline 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
