### VARIABLES GLOBALES ###
$global:TYPE_FORENSIC = "Forensic"
$global:DISTRIB_FORENSIC = "Ubuntu"
$global:REPERTOIRE_OVA = "VirtualBoxForensic"
$global:NOM_BASE_VM = "Forensic"
$global:VIRTUALBOXMANAGE = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$global:VIRTUALBOX = "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe"
$global:PACKER_UBUNTU = "ubuntu.json.pkr.hcl"
$global:PACKER_VARIABLE = "variables.pkrvars.hcl"
$global:PACKER_LINUX = "autoinstall.yaml"
$global:PACKER_PROVISIONER = "forensic.sh"

########################################################
##### Recuperation du nom de l'hote et de la date ######
########################################################
$Host_method = Get-Host
$date_export = Get-Date -Format "yyyy-MM-dd"

########################################################
##### Instantiation de la classe d'installation ########
########################################################
Class CInstallation{
    [boolean]$online                 #acces a internet
    [boolean]$export                 #exportation pour une future installation hors-ligne
    [boolean]$nettoyage              #suppression de toutes traces sur le PC actuel
    [boolean]$virtualbox             #virtualbox deja installe
    [boolean]$zip7                   #7-zip deja installe

    [string]$chemin_base             #chemin de l'execution du script PS1
    [string]$chemin_log				 #chemin du fichier de log de l'installation
	
    [string]$chemin_script           #chemin de l'execution pour les scripts Linux Forensic
    [string]$chemin_script_forensic  #chemin complet vers le script forensic 
    [string]$chemin_script_preseed   #chemin complet vers le fichier preseed
    [string]$chemin_script_ubuntu    #chemin complet vers le fichier HCL pour packer ubuntu
    [string]$chemin_script_variables #chemin complet vers le fichier de variables pour packer
    [string]$ipaddress               #adresse IP de l'hote du script

	[string]$chemin_forensic		 #chemin du dossier pour le forensic
	[string]$chemin_forensic_dumps	 #chemin du dossier pour les elements extraits
	[string]$chemin_forensic_extract #chemin du dossier pour les elements suspicieux
	[string]$chemin_forensic_tools	 #chemin du dossier pour les outils Windows sans installation
	
	[string]$chemin_repertoire_VM    #chemin du repertoire en lien avec la VM
    [string]$nom_vm                  #nom de la VM
    [string]$nom_ova                 #nom du fichier OVA associe a la VM
    [string]$chemin_ova              #chemin complet vers l'OVA de la VM
    
	[string]$chemin_logiciels        #chemin des logiciels hors-ligne
    [string]$chemin_export           #chemin pour l'exportation des elements le cas echeant

	CInstallation(){
        if(Get-Package | where name -match "VirtualBox"){
            $this.virtualbox = $true
        }
        else{
            $this.virtualbox = $false
        }
        if(Get-Package | where name -match "7-zip"){
            $this.zip7 = $true
        }
        else{
            $this.zip7 = $false
        }
    }

	EnLigne(){
        # Verification de la connexion internet
        Write-Host "Verification de la connexion Internet (via ping)" -foregroundcolor DarkGreen -backgroundcolor White

	    $ip = Get-NetIPAddress -AddressState Preferred -AddressFamily IPv4 | Select-Object IPAddress,InterfaceAlias |Where-Object { $_.InterfaceAlias -contains "Ethernet" }
        if(-not($ip)){
		    $ip = Get-NetIPAddress -AddressState Preferred -AddressFamily IPv4 | Select-Object IPAddress,InterfaceAlias |Where-Object { $_.InterfaceAlias -contains "Wi-Fi" }
        }
        if($ip){
		    if ($ip.IPAddress -match '^169.254.'){
        		$this.online = $false
		    }
		    else{
			    if (Test-Connection "www.google.fr" -Count 1 -Quiet){
            		$this.online = $true
                    $this.ipaddress = $ip.IPAddress
			    }
			    else{
            		$this.online = $false
			    }
		    }
	    }
	    else{
		    Write-Host "Aucune carte reseau n'est connectee a Internet" -ForegroundColor DarkRed -BackgroundColor White
    		$this.online = $false
	    }
	}

    #Creation des variables de chemin pour les outils forensic
    CheminForensic(){
		# Repertoire pour le forensic sous Windows
		Add-Type -AssemblyName System.Windows.Forms
		$Question_chemin_forensic = New-Object System.Windows.Forms.FolderBrowserDialog
		$Question_chemin_forensic.Description = "!!! CHOIX DU DOSSIER POUR LES OUTILS FORENSIC !!!"
		[void]$Question_chemin_forensic.ShowDialog()
		$this.chemin_forensic = $Question_chemin_forensic.SelectedPath + "\_Forensic\"
        $this.chemin_forensic_dumps = $this.chemin_forensic + "dumps\"
        $this.chemin_forensic_extract = $this.chemin_forensic + "extract\"
        $this.chemin_forensic_tools = $this.chemin_forensic + "tools\"
    }

    #Creation des variables de chemin pour les scripts Linux
	CheminScript($chemin_base){
		# Chemins concernants les scripts a executer
        $this.chemin_script = $chemin_base + "script\"
        $this.chemin_script_forensic = $this.chemin_script + "forensic.sh"
        $this.chemin_script_preseed = $this.chemin_script + "preseed.cfg"
        $this.chemin_script_ubuntu = $this.chemin_script + $global:PACKER_UBUNTU
        $this.chemin_script_variables = $this.chemin_script + $global:PACKER_VARIABLE
	}

    #Creation des variables de chemin pour la VM
	CheminVM($chemin_base,$date_export){
        #Definition du chemin de la future VM exportee
        $this.chemin_repertoire_VM = $this.chemin_base + $global:REPERTOIRE_OVA + "\"
        $this.nom_vm = $global:NOM_BASE_VM + "_" + $date_export
        $this.nom_ova = $this.nom_vm + ".ova"
        $this.chemin_ova = $this.chemin_repertoire_VM + $this.nom_ova
	}
	
    #Creation des variables de chemin pour le fichier de log et les logiciels telecharges
	CheminAutre($chemin_base,$date_export){
		# Chemin du fichier de log
        $this.chemin_log=$this.chemin_base + "Telechargement_"+$date_export+".log"
        #Definition du chemin des logiciels a installer sous Windows
        $this.chemin_logiciels = $this.chemin_base + "logiciels\"
		#Creation du repertoire Logiciels
		if(-not(Test-Path $this.chemin_logiciels)){
			Write-Host "Creation du repertoire hors-ligne de mise a jour Windows" -ForegroundColor DarkBlue -BackgroundColor White
			New-Item -ItemType Directory -Force -Path $this.chemin_logiciels
		}
	}

    #Verification de la volonte d'exportation
	Exportation($Host_method,$chemin_base){
		$titre = "Exportation"
        $question = 'Voulez-vous exporter le resultat ?'
        $choix_export  = '&Non', '&Oui'

        $this.export = [System.Convert]::ToBoolean($Host_method.UI.PromptForChoice($titre, $question, $choix_export, 0))

        if($this.export -eq $true){
            $this.chemin_export = $chemin_base + "EXPORTATION\"
        }
	}

    #Verification de la volonte de garder l'hote le plus propre possible	
	Nettoyeur($Host_method){
		$titre = "Nettoyage"
		$question = "Voulez-vous nettoyer la machine hote a l'issue?"
        $choix_nettoyage  = '&Non', '&Oui'

        $this.nettoyage = [System.Convert]::ToBoolean($Host_method.UI.PromptForChoice($titre, $question, $choix_nettoyage, 0))
    }
}

################################################
##### Fonction de creation de repertoire #######
################################################
function WindowsConfiguration([string]$chemin,[string]$chemin_log){
	#Creation des dossiers de Forensic et parametrage exclusion Defender
	Write-Host "Creation du dossier Forensic "$chemin -ForegroundColor DarkBlue -BackgroundColor White
    $log = 'Creation du dossier Forensic '+$chemin
    Add-Content $chemin_log $log
	New-Item -ItemType Directory -Force -Path $chemin
}
    
#################################################################################
##### Fonction de mise en place des droits sur le repertoire d'extraction #######
#################################################################################
function DirectoryRights([string]$chemin_extract,[string]$chemin_log){
	#Interdiction de l'execution de programmes depuis le repertoire Extract
	$acl = Get-ACL -Path $chemin_extract
	#Suppression de l'heritage et des permissions
	$acl.SetAccessRuleProtection($true,$false)
	$acl | Set-Acl -Path $chemin_extract
	#Ajout de la regle de controle totale sur le dossier "extract"
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("Tout le monde","FullControl","ContainerInherit","None","Allow")
	$acl.SetAccessRule($accessrule)
	$acl |set-acl -Path $chemin_extract
	#Ajout de la regle de LECTURE SEULE pour les fichiers dans le repertoire "extract"
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("Tout le monde","Write, Read, Synchronize","ObjectInherit","NoPropagateInherit, InheritOnly","Allow")
	$acl.AddAccessRule($accessrule)
	$acl |set-acl -Path $chemin_extract
    $log = 'Mise en place des droits sur le dossier '+$chemin_extract
    Add-Content $chemin_log $log
}	

########################################################
##### Fonctions de verification de l'arborescence ######
########################################################
function CheckArboScriptsOnline([string]$chemin_script,[string]$chemin_log){
    write-host "Verification de l'arborescence necessaire a l'installation EN LIGNE" -ForegroundColor DarkGreen -BackgroundColor White

    #Configuration des fichiers a verifier
    $fichiers_linux = New-Object System.Collections.ArrayList
    $fichiers_linux.AddRange(($global:PACKER_PROVISIONER,$global:PACKER_LINUX,$global:PACKER_UBUNTU,$global:PACKER_VARIABLE))

    foreach ($fichier in $fichiers_linux){
        $chemin = $chemin_script + $fichier
        if(-not(Test-Path $chemin)){
            $log = "ERREUR : "+$chemin+" MANQUANT !!"
            Add-Content $chemin_log $log
            Write-Host $chemin "est absent" -ForegroundColor DarkBlue -BackgroundColor Red
            write-host "!!!!!! FICHIER MANQUANT !!!!!!"  -ForegroundColor DarkBlue -BackgroundColor Red
            Write-Host 'Press any key to continue...';
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            exit
        }
    }

    if(-not(Test-Path ".\script\Install")){
            $log = "ERREUR : "+"Dossier .\script\Install MANQUANT !!"
            Add-Content $chemin_log $log
            write-host "!!!!!! DOSSIER MANQUANT !!!!!!"  -ForegroundColor DarkBlue -BackgroundColor Red
            Write-Host 'Press any key to continue...';
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            exit
    }
    if(-not(Test-Path ".\script\NoInstall")){
            $log = "ERREUR : "+"Dossier .\script\Install MANQUANT !!"
            Add-Content $chemin_log $log
            write-host "!!!!!! DOSSIER MANQUANT !!!!!!"  -ForegroundColor DarkBlue -BackgroundColor Red
            Write-Host 'Press any key to continue...';
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            exit
    }
}


function CheckArboArchivesOffline([string]$chemin_base,[string]$chemin_log){
    write-host "Verification de l'arborescence necessaire a l'installation HORS LIGNE" -ForegroundColor DarkGreen -BackgroundColor White
    $chemin_fichiers_exportes = $chemin_base + "EXPORTATION\"

    #Configuration des fichiers a verifier
    $fichiers_exportes = New-Object System.Collections.ArrayList
    $fichiers_exportes.AddRange(("Forensic-tools.zip","Logiciels-Windows.zip","Forensic*.ova"))

    foreach ($fichier in $fichiers_exportes){
        $chemin = $chemin_fichiers_exportes + $fichier
        if(-not(Test-Path $chemin)){
            Write-Host $chemin "MANQUANT" -ForegroundColor DarkBlue -BackgroundColor Red
            write-host "!!!!!! FICHIERS MANQUANTS !!!!!!"  -ForegroundColor DarkBlue -BackgroundColor Red
            Write-Host 'Press any key to continue...';
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            exit
        }
    }
}

################################################
##### Fonction de creation de la VM Linux ######
################################################
function PackerRecuperation($installation){
    #Recuperation ET DECOMPRESSION de Packer
    $packer_source = "https://developer.hashicorp.com/packer/install"
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Telechargement et decompression Packer (environ 70Mo)" -ForegroundColor DarkBlue -BackgroundColor White
    $packer = $(@(Invoke-WebRequest -Uri $packer_source -UseBasicParsing).links.href) -match "windows" -match "64"
    $packer_dl = $packer[0]
    $packer_version = $packer_dl.split("/")[-1]
    $packer_sauvegarde = $installation.chemin_script + $packer_version
    Invoke-WebRequest -Uri $packer_dl -UseBasicParsing -OutFile $packer_sauvegarde
    Expand-Archive -Force -DestinationPath $installation.chemin_script $packer_sauvegarde

    Remove-Item -Force $packer_sauvegarde	
}

function UbuntuRecuperation($installation){
    #Recuperation de Ubuntu
    $ubuntu_source = "https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-amd64.iso"
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Telechargement Ubuntu Live Server 22.04.4 (environ 2.1Go)" -ForegroundColor DarkBlue -BackgroundColor White
    $ubuntu_version = $ubuntu_source.split("/")[-1]
    $ubuntu_sauvegarde = $installation.chemin_script + $ubuntu_version
    Invoke-WebRequest -Uri $ubuntu_source -UseBasicParsing -OutFile $ubuntu_sauvegarde	
}

function LinuxParametrage($installation)
{
    #Configuration du fichier $global:PACKER_VARIABLE pour l'export et la conservation de la VM
    #Exportation
    if($installation.export){
        (Get-Content -Path $installation.chemin_script_variables) |
        ForEach-Object {$_ -Replace 'skip_export = "true"', 'skip_export = "false"'} |
            Set-Content -Path $installation.chemin_script_variables
    }
    #Sans Exportation
    if(-not ($installation.export)){
        (Get-Content -Path $installation.chemin_script_variables) |
        ForEach-Object {$_ -Replace 'skip_export = "false"', 'skip_export = "true"'} |
            Set-Content -Path $installation.chemin_script_variables
    }

    #Machine virtuelle a ne pas conserver
    if($installation.nettoyage){
        (Get-Content -Path $installation.chemin_script_variables) |
        ForEach-Object {$_ -Replace 'keep_registered = "true"', 'keep_registered = "false"'} |
            Set-Content -Path $installation.chemin_script_variables
    }
    #Machine virtuelle a conserver
    if(-not ($installation.nettoyage)){
        (Get-Content -Path $installation.chemin_script_variables) |
        ForEach-Object {$_ -Replace 'keep_registered = "false"', 'keep_registered = "true"'} |
            Set-Content -Path $installation.chemin_script_variables
    }

    #Nommage de la machine virtuelle
    $regex = 'vm_name = "' + $global:NOM_BASE_VM +'_\d\d\d\d-\d\d-\d\d"'
    $remplacement = 'vm_name = "' + $installation.nom_VM + '"'
    (Get-Content -Path $installation.chemin_script_variables) -replace $regex, $remplacement |Set-Content $installation.chemin_script_variables

    #Adresse IP du PC Hote (devenu obligatoire suite a un pb avec VBox 7.0)
    $regex = 'host_ip = "\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}"'
    $remplacement = 'host_ip = "' + $installation.ipaddress + '"'
    (Get-Content -Path $installation.chemin_script_variables) -replace $regex, $remplacement |Set-Content $installation.chemin_script_variables

}

function LinuxCreation($installation){
    PackerRecuperation($installation)
    UbuntuRecuperation($installation)
    LinuxParametrage($installation)

    #Lancement de la creation de la machine via Packer
    $log = "Creation Linux"
    Add-Content $installation.chemin_log '*************************'
    Add-Content $installation.chemin_log $log
    Add-Content $installation.chemin_log '*************************'
    write-host "Creation Linux"  -ForegroundColor DarkBlue -BackgroundColor White

    #Démarrage de VirtualBox afin d'éviter les freeze Packer
#    & $global:VIRTUALBOX
	
	#Mise en place des éléments de Packer
    $chemin_origine = Get-Location
    Set-Location -Path $installation.chemin_script
    $packer = $installation.chemin_script + "packer.exe"

    $arguments = "plugins install github.com/hashicorp/virtualbox"
    Start-Process -NoNewWindow -Wait -FilePath $packer -ArgumentList $arguments
#    $arguments = "plugins install github.com/hashicorp/vmware"
#    Start-Process -NoNewWindow -Wait -FilePath $packer -ArgumentList $arguments

    $arguments = " build -on-error=ask -var-file=" + $installation.chemin_script_variables + " " +$installation.chemin_script_ubuntu
    Start-Process -NoNewWindow -Wait -FilePath $packer -ArgumentList $arguments

    Set-Location -Path $chemin_origine

    #Suppression de l'iso Linux
    Get-ChildItem $installation.chemin_script -Include *.iso -Recurse | Remove-Item

    #Suppression de l'executable packer
    Get-ChildItem $installation.chemin_script -Include *.exe -Recurse | Remove-Item

    #Creation du repertoire partage si besoin
    if(-not ($installation.nettoyage)){
        LinuxPartage $installation.chemin_forensic
    }

    #Suppression des vestiges de Packer
    $chemin_packer_cache = $installation.chemin_script + "packer_cache\"
    Remove-Item -Force -Recurse $chemin_packer_cache
}

##################################################
##### Fonction d'import de l'OVA VirtualBox ######
##################################################
function LinuxOvaImport($chemin_base,$chemin_forensic,$chemin_log){
    $ova = Get-ChildItem -Recurse -Path $chemin_base -Include *.ova
    $ova_path = '"' + $ova[0].FullName + '"'
    $parameter = "import " + $ova_path
    Start-Process -NoNewWindow -Wait -FilePath $global:VIRTUALBOXMANAGE -ArgumentList $parameter

    $log = "Linux importe"
    Add-Content $installation.chemin_log '*************************'
    Add-Content $chemin_log $log
    Add-Content $installation.chemin_log '*************************'
    write-host "Linux importe"  -ForegroundColor DarkBlue -BackgroundColor White

    #Creation du repertoire partage
    LinuxPartage $chemin_forensic
}


###############################################################
##### Fonction de mise en place du partage hote/VM Linux ######
###############################################################
function LinuxPartage([string]$chemin_forensic){
    #Recuperation de l'ID de la VM Forensic
    start-Process -NoNewWindow -Wait -FilePath $global:VIRTUALBOXMANAGE -ArgumentList "list vms" -RedirectStandardOutput "vmlistSource.txt"

    #Creation de l'expression reguliere
    $regex = '"'+$global:NOM_BASE_VM +'_\d\d\d\d-\d\d-\d\d"'

    #Recuperation des VM existantes dans VirtualBox correspondantes a l'expression reguliere
    $vm = $(Get-Content "vmlistSource.txt")
    
    #Si une VM existe dans VirtualBox
    if($vm){

        #Si une seule VM existe dans VirtualBox
        if ($vm.gettype().Name -eq "String"){
            #Si la machine correspond a l'expression reguliere, on garde le nom
            if($vm -match $regex){
                $vm_en_cours = $vm
            }
            #sinon on prevoit une valeur $null
            else{
                $vm_en_cours = $null
            }
        }
        #Si VirtualBox contient plusieurs VM
        else{
            #On recupere toutes les VM correspondant a l'expression reguliere
            $vm_temp = ($vm -match $regex)

            #Si aucune VM ne correspondait, on prevoit une valeur $null
            if(-not($vm_temp)){
                $vm_en_cours = $null
            }
            #Sinon on ne conserve que la derniere VM dans la liste
            else{
                $vm_en_cours = $vm_temp[-1]
            }
        }

        #Si une machine Forensic a ete trouve, creation du partage
        if($vm_en_cours){
            #Recuperation de l'ID de la VM
            $vm_id = $vm_en_cours.split(" ")[-1]
            $vm_id = $vm_id.Replace("{","").Replace("}","")

            #Mise en place du partage
            $Name = "Forensic"
            $parameter = "sharedfolder add " + $vm_id + " --name " + $Name + " --hostpath " + $chemin_forensic + " --automount"
            Start-Process -NoNewWindow -Wait -FilePath $global:VIRTUALBOXMANAGE -ArgumentList $parameter
        }
    }

    #Suppression du fichier temporaire
    Remove-Item -Force "vmlistSource.txt"
}

############################################################################
##### Fonction d'exportation des outils telecharges et de la VM Linux ######
############################################################################
function Exportation($installation){
    New-Item -ItemType Directory -Force -Path $installation.chemin_export
    $date_export = Get-Date -Format "yyyy-MM-dd"

    #Compression des logiciels windows dans l'archive Logiciels-Windows.zip
    $zip_logicielswindows = $installation.chemin_export + "Logiciels-Windows.zip"
    Write-Host "Compression logiciels Windows dans "$zip_logicielswindows -ForegroundColor DarkBlue -BackgroundColor White
    Compress-Archive -Path $installation.chemin_logiciels -DestinationPath $zip_logicielswindows

    #Compression des Tools recuperes dans l'archive "Forensic-Tools.zip"
    $chemin_fichier_zip = $installation.chemin_export + $global:TYPE_FORENSIC + "-Tools.zip"
    Write-Host "Compression du dossier Tools dans "$chemin_fichier_zip -ForegroundColor DarkBlue -BackgroundColor White
    Compress-Archive -Path $installation.chemin_forensic_tools -DestinationPath $chemin_fichier_zip

    #Deplacement de la machine virtuelle
    $destination_ova = $installation.chemin_export + $installation.nom_ova
    Write-Host "Deplacement de la machine virtuelle vers "$destination_ova -ForegroundColor DarkBlue -BackgroundColor White
    try{
        Move-Item -Path $installation.chemin_ova -Destination $destination_ova
    }
    catch{
        Write-Host "!!! L'OVA N'A PAS PU ETRE DEPLACE !!!" -ForegroundColor White -BackgroundColor Red
    }

    #Compression des fichiers recuperes (tar, zip et ps1) dans une unique archive
    Write-Host "Compression vers EXPORTATION.zip" -ForegroundColor DarkBlue -BackgroundColor White
        #parametrage du nom de fichier de sortie
    $nom_fichier_export = $installation.chemin_base + 'EXPORTATION-' + $global:TYPE_FORENSIC + $date_export + '.zip'
        #parametrage des arguments a passer a 7z pour la creation de l'archive
    $arguments = 'a ' + $nom_fichier_export + ' -tzip '+$installation.chemin_export+' '+$installation.chemin_base+'Setup.bat '+$installation.chemin_base+'Principal.ps1 ' +$installation.chemin_script
        #Creation de l'archive
    Start-Process -Wait 'C:\Program Files\7-zip\7z.exe' -ArgumentList $arguments
        #Suppression du dossier d'exportation
    Remove-Item -Force -Recurse $installation.chemin_export
}

#####################################################################
##### Fonction de suppression des elements presents sur l'hote ######
#####################################################################
function Nettoyage($installation){
    #Suppression des dossiers crees
    Write-Host "Suppression du dossier " $installation.chemin_forensic -foregroundcolor DarkBlue -backgroundcolor White
    Remove-Item -Recurse -Force $installation.chemin_forensic
    
    #suppression des executables recopies
    Write-Host "Suppression des executables pour Windows" -foregroundcolor DarkBlue -backgroundcolor White
    Remove-Item -Force -Recurse -Path $installation.chemin_logiciels

    #suppression du repertoire VirtualBox cree
    Write-Host "Suppression du repertoire VirtualBox cree" -foregroundcolor DarkBlue -backgroundcolor White
    Remove-Item -Force -Recurse -Path $installation.chemin_repertoire_VM

    #Installation du gestionnaire de packages Nuget si besoin
    if(-not($installation.virtualbox) -Or -not($installation.zip7)){
        Write-Host "Installation du gestionnaire de packages NuGet" -foregroundcolor DarkBlue -backgroundcolor White
        Add-Content $installation.chemin_log "Installation du gestionnaire de packages NuGet"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    }

    #Desinstallation de Virtualbox si Virtualbox n'etait pas present sur la machine
    if(-not($installation.virtualbox))
    {   
        Write-Host "Suppression de VirtualBox" -foregroundcolor DarkBlue -backgroundcolor White
        Add-Content $installation.chemin_log "Desinstallation de Virtualbox"
#        Uninstall-Package -Name $virtualbox_name.Name
        $arguments = " remove --id Oracle.VirtualBox"
        Start-Process -Wait winget -ArgumentList $arguments
        $arguments = " remove --id Microsoft.VCRedist.2015+.x64"
        Start-Process -Wait winget -ArgumentList $arguments
        $arguments = " remove --id Microsoft.VCRedist.2015+.x86"
        Start-Process -Wait winget -ArgumentList $arguments
    }
    #Desinstallation de 7-Zip si 7-zip n'etait pas present sur la machine
    if(-not($installation.zip7)){
        Write-Host "Suppression de 7-zip" -foregroundcolor DarkBlue -backgroundcolor White
        Add-Content $installation.chemin_log "Desinstallation de 7-zip"
        $arguments = " remove --id 7zip.7zip"
        Start-Process -Wait winget -ArgumentList $arguments
    }
}

########################################################################################
##### Fonction de decompression des fichiers zip pour une installation hors-ligne ######
########################################################################################
function Decompression($chemin_base,$chemin_logiciels,$chemin_forensic_tools,$chemin_log){
    #Parametrage du dossier contenant l'exportation si l'installation est faite depuis un export precedent
    $dossier_exportation = Get-ChildItem -Recurse -Include 'EXPORTATION' -Path $chemin_base |Select-Object Fullname

    if($dossier_exportation){
        $logiciels_zip_temp = $dossier_exportation.FullName + "\Logiciels-Windows.zip"
        $forensic_zip_temp = $dossier_exportation.FullName + "\Forensic-Tools.zip"

        #Decompression du zip contenant les logiciels Windows
        if(Test-Path $logiciels_zip_temp){
            Write-Host "Decompression du depot local Windows" -foregroundcolor DarkBlue -backgroundcolor White
            Add-Content $chemin_log "Decompression des logiciels Windows"
            #suppression du contenu du repertoire s'il existe deja (afin d'eviter les conflits)
            if(Test-Path $chemin_logiciels){
                Remove-Item -Force -Recurse $chemin_logiciels
            }
            #decompression de l'archive
            Expand-Archive -Force -DestinationPath $chemin_base $logiciels_zip_temp
        }

        #Decompression du zip contenant les logiciels Forensic
        if(Test-Path $forensic_zip_temp){
            Write-Host "Decompression du depot local Tools" -foregroundcolor DarkBlue -backgroundcolor White
            Add-Content $chemin_log "Decompression des outils Forensic"
            Remove-Item -Force -Recurse $chemin_forensic_tools
            Expand-Archive -Force -DestinationPath $chemin_forensic_tools $forensic_zip_temp
        }
    }
}


##################################
##### Fonction principale ########
##################################
#Passage en mode administrateur
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::"Administrator")) {
    $Arguments = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -Verb RunAS -ArgumentList $arguments
    exit
}

#Configuration du chemin relatif
$chemin_base = $MyInvocation.MyCommand.Definition
$chemin_base = Split-Path $chemin_base
$chemin_base = $chemin_base + '\'
Set-Location -Path $chemin_base

#Creation de l'objet contenant les parametres d'installation
$installation = New-Object CInstallation
$installation.EnLigne()
$installation.CheminForensic()
$installation.CheminScript($chemin_base)
$installation.CheminVM($chemin_base,$date_export)
$installation.CheminAutre($chemin_base,$date_export)

#Si on accede a Internet
if ($installation.online){
    #Demande utilisateur
    #-------------------
	$installation.Exportation($Host_method,$chemin_base)
    
	if($installation.export){
		$installation.Nettoyeur($Host_method)
	}
	else{
		$installation.nettoyage = $false
	}

    #Verification
    #------------
    #Verification de l'arborescence
    Write-Host 'Verification de l arborescence' -ForegroundColor DarkBlue -BackgroundColor White
    CheckArboScriptsOnline $installation.chemin_script $installation.chemin_log

    #Mise en place des elements Windows
    #----------------------------------
    #Creation des dossiers Windows et configuration des droits
    Write-Host "Creation de l'exclusion "$installation.chemin_forensic_extract" dans DEFENDER" -foregroundcolor DarkBlue -backgroundcolor White
    WindowsConfiguration $installation.chemin_forensic_dumps $installation.chemin_log
    WindowsConfiguration $installation.chemin_forensic_extract $installation.chemin_log
    WindowsConfiguration $installation.chemin_forensic_tools $installation.chemin_log
    Add-MpPreference -ExclusionPath $installation.chemin_forensic_extract
    DirectoryRights $installation.chemin_forensic_extract $installation.chemin_log

    #Telechargement des logiciels a installer
    Add-Content $installation.chemin_log 'Debut des telechargements'
    Add-Content $installation.chemin_log '*************************'
    #Logiciels a installer
    try{
        Get-ChildItem ".\script\Install" -ErrorAction stop -Filter *.ps1 | Foreach-Object{
			Unblock-File -Path $installation.chemin_logiciels
            Write-Host $_.FullName -ForegroundColor White -BackgroundColor Green
	        & $_.FullName download $installation.chemin_logiciels $installation.chemin_log
        }
    }
    catch{
	    write-host "Erreur de telechargement " -BackgroundColor Red
        $texte_erreur = 'Erreur '+$_FullName
	    Add-Content $installation.chemin_log $texte_erreur
	    Add-Content $installation.chemin_log '--------------------------'
    }


    #Logiciels stand-alone
    try{
        Get-ChildItem ".\script\NoInstall" -ErrorAction stop -Filter *.ps1 | Foreach-Object{
            Write-Host $_.FullName -ForegroundColor White -BackgroundColor Green
	        & $_.FullName download $installation.chemin_forensic_tools $installation.chemin_log
        }
    }
    catch{
	    write-host "Erreur de telechargement " -BackgroundColor Red
        $texte_erreur = 'Erreur '+$_FullName
	    Add-Content $installation.chemin_log $texte_erreur
	    Add-Content $installation.chemin_log '-----------------'
    }

    #Installation des logiciels
    #Si on ne veut pas revenir a l'etat d'origine du PC
    if(-not($installation.nettoyage)){
        Add-Content $installation.chemin_log 'Debut des installations'
        Add-Content $installation.chemin_log '***********************'
        try{
            Get-ChildItem ".\script\Install" -ErrorAction stop -Filter *.ps1 | Foreach-Object{
	            & $_.FullName install $installation.chemin_logiciels $installation.chemin_log
            }
        }
        catch{
	        write-host "Erreur d'installation "+$_FullName -BackgroundColor Red
	        $texte_erreur = 'Erreur '+$_FullName
	        Add-Content $installation.chemin_log $texte_erreur
	        Add-Content $installation.chemin_log '-----------------'
        }        
    }
    #Si on veut revenir a l'etat d'origine du PC
    else{
        #Installation de 7z s'il n'est pas installe
        if(-not($installation.zip7)){
            Get-ChildItem ".\script\Install" -ErrorAction stop -Filter 7z*.ps1 | Foreach-Object{
	            & $_.FullName install $installation.chemin_logiciels $installation.chemin_log
            }
        }
        #Installation de Virtualbox s'il n'est pas installe
        if(-not($installation.virtualbox)){
            Get-ChildItem ".\script\Install" -ErrorAction stop -Filter Microsoft.VCRedist-x64.ps1 | Foreach-Object{
	            & $_.FullName install $installation.chemin_logiciels $installation.chemin_log
            }
            Get-ChildItem ".\script\Install" -ErrorAction stop -Filter Microsoft.VCRedist-x86.ps1 | Foreach-Object{
	            & $_.FullName install $installation.chemin_logiciels $installation.chemin_log
            }
            Get-ChildItem ".\script\Install" -ErrorAction stop -Filter VirtualBox*.ps1 | Foreach-Object{
	            & $_.FullName install $installation.chemin_logiciels $installation.chemin_log
            }
        }
    }

Write-Host 'DEMARRAGE DE LA PARTIE VM VirtualBox' -ForegroundColor White -BackgroundColor Green

    #Mise en place des elements Linux
    #--------------------------------
    #Creation de la machine Linux
    if(Get-WmiObject -Class Win32_Product |where name -match "VirtualBox"){
        LinuxCreation($installation)
        Write-Host "VIRTUALBOX EST INSTALLE !!" -ForegroundColor White -BackgroundColor Green
    }
    else{
        Write-Host "VIRTUALBOX N'EST PAS INSTALLE !!" -ForegroundColor White -BackgroundColor Red
    }

    #Exportation et nettoyage
    #------------------------
    #Exportation si desiree
    if($installation.export){
        Exportation($installation)
        if($installation.nettoyage){
            Nettoyage($installation)
        }
    }
}

#Si on N'accede PAS a Internet
if (-not($installation.online)){
    #Verification
    #------------
    #Verification de l'arborescence
    CheckArboArchivesOffline $installation.chemin_base $installation.chemin_log

    #Mise en place des elements
    #--------------------------
    WindowsConfiguration $installation.chemin_forensic_dumps $installation.chemin_log
    WindowsConfiguration $installation.chemin_forensic_extract $installation.chemin_log
    WindowsConfiguration $installation.chemin_forensic_tools $installation.chemin_log
    Write-Host "Creation de l'exclusion "$installation.chemin_forensic_extract" dans DEFENDER" -foregroundcolor DarkBlue -backgroundcolor White
    Add-MpPreference -ExclusionPath $installation.chemin_forensic_extract
    DirectoryRights $installation.chemin_forensic_extract $installation.chemin_log

    #Decompression des fichiers utiles
    #---------------------------------
    Decompression $chemin_base $installation.chemin_logiciels $installation.chemin_forensic_tools $installation.chemin_log

    #Installation des logiciels
    #--------------------------
    Add-Content $installation.chemin_log 'Debut des installations'
    Add-Content $installation.chemin_log '***********************'
    try{
        Get-ChildItem ".\script\Install" -ErrorAction stop -Filter *.ps1 | Foreach-Object{
	        & $_.FullName install $installation.chemin_logiciels $installation.chemin_log
        }
    }
    catch{
	    write-host "Erreur d'installation "+$_FullName -BackgroundColor Red
	    $texte_erreur = 'Erreur '+$_FullName
	    Add-Content $installation.chemin_log $texte_erreur
	    Add-Content $installation.chemin_log '-----------------'
    }

    #Importation de la VM Linux SIFT
    #-------------------------------
    LinuxOvaImport $chemin_base $installation.chemin_forensic $installation.chemin_log
}


Write-Host 'INSTALLATION TERMINEE...' -ForegroundColor White -BackgroundColor Green
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
Write-Host -NoNewline 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
