#!/bin/bash
packages_depot=(
 "pff-tools"
 "binwalk"
 "mariadb-server"
)

#SIFT_CLI_LINUX="https://github.com/sans-dfir/sift-cli/releases/download/v1.10.0/sift-cli-linux"
SIFT_CLI_LINUX="https://github.com/sans-dfir/sift-cli/releases/download/v1.13.1/sift-cli-linux"
CAPA="https://github.com/mandiant/capa/releases/latest/"
DUMPZILLA="http://www.dumpzilla.org/dumpzilla.py"
FLOSS="https://github.com/fireeye/flare-floss/releases/download/v1.7.0/floss-v1.7.0-linux.zip"
SIGMA="https://github.com/SigmaHQ/sigma"
VOLATILITY3="https://github.com/volatilityfoundation/volatility3.git"
ZIRCOLITE="https://github.com/wagga40/Zircolite"
ZIRCOLITE_DOC="https://github.com/wagga40/Zircolite/raw/master/docs/Zircolite_manual.pdf"
FENRIR="https://github.com/Neo23x0/Fenrir"
LOKI="https://github.com/Neo23x0/Loki"
LOKI_SIGNATURE="https://github.com/Neo23x0/signature-base"

Etape10_disableautomaticupdate(){
	echo "---------------------------------------------------------------------"
	echo "DESACTIVATION de la MISE A JOUR AUTOMATIQUE"
	echo "---------------------------------------------------------------------"

	sudo sed -i 's/1/0/g' /etc/apt/apt.conf.d/20auto-upgrades
}

Etape20_upgrade() {
	echo "---------------------------------------------------------------------"
	echo "Début de la MISE A JOUR"
	echo "---------------------------------------------------------------------"

	sudo add-apt-repository -y ppa:gift/stable
	sudo apt update
	sudo apt-get -f install
	
	echo "MISE A JOUR TERMINEE"
}

Etape30_install_sift(){
	echo "---------------------------------------------------------------------"
	echo "Début de l'installation de la SIFT"
	echo "---------------------------------------------------------------------"

	sudo curl -Lo /usr/local/bin/sift $SIFT_CLI_LINUX
	sudo chmod +x /usr/local/bin/sift
	sudo sift install

	echo "SIFT INSTALLEE"
}

Etape40_install_packaged_tools(){
	echo "---------------------------------------------------------------------"
	echo "Début de l'installation des PACKAGES SUPPLEMENTAIRES"
	echo "---------------------------------------------------------------------"

	for package in "${packages_depot[@]}"
	do
		echo "---------------------------------------------------------------------"
		echo "Installation du package $1"
		echo "---------------------------------------------------------------------"		
		sudo apt install -y $package
		if [ $? -ne 0 ]; then
			echo "*********************************************************************"
			echo "************** IMPOSSIBLE D'INSTALLER LE PACKAGE $1 *****************"
			echo "*********************************************************************"
		fi
	done

	echo "PACKAGES SUPPLEMENTAIRES INSTALLES"
}

Etape50_install_unpacked_tools(){
	echo "---------------------------------------------------------------------"
	echo "Début de l'installation des OUTILS INDEPENDANTS"
	echo "---------------------------------------------------------------------"

	sudo mkdir /TOOLS
	cd /TOOLS

	#Capa
	echo " >>>>>>  Installation de Capa "
	#Recherche de la dernière version de CAPA
	CAPA_niv1=$(curl $CAPA)
	CAPA_niv2=$(echo $CAPA_niv1 | cut -d'"' -f2)
	CAPA_niv3=$(curl $CAPA_niv2 |grep linux.zip)
	CAPA_niv4="https://github.com"$(echo $CAPA_niv3 |cut -d'"' -f2)
	#Récupération de CAPA
	sudo wget $CAPA_niv4
	#Mise en place de CAPA
	CAPA_file=$(echo $CAPA_niv4 | rev |cut -d'/' -f1 | rev)
	sudo unzip $CAPA_file
	sudo rm $CAPA_file
	#Ajout de CAPA dans le fichier de documentation
	echo "CAPA" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "----" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "CAPA detects capabilities in executable files. You run it against a PE, ELF, or shellcode file and it tells you what it thinks the program can do. For example, it might suggest that the file is a backdoor, is capable of installing services, or relies on HTTP to communicate." | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	#Dumpzilla
	echo " >>>>>>  Installation de Dumpzilla "
	sudo wget $DUMPZILLA
	arrDUMP=(${DUMPZILLA//// })
	sudo chmod +x ${arrDUMP[-1]}
	echo "DUMPZILLA" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "---------" | sudo tee -a /TOOLS/README_for_tools.txt
    echo "extract all forensic interesting information of Firefox, Iceweasel and Seamonkey browsers to be analyzed" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	#Floss
	echo " >>>>>>  Installation de Floss "
	sudo wget $FLOSS
	arrFLOSS=(${FLOSS//// })
	sudo unzip ${arrFLOSS[-1]}
	sudo rm ${arrFLOSS[-1]}
	echo "FLOSS" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "-----" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "FLARE Obfuscated String Solver (FLOSS) - Automatically extract obfuscated strings from malware. " | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	#Oletools
	echo " >>>>>>  Installation de Oletools "
		#Désactivation de la demande de KDE Wallet Service
	sudo python -m keyring --disable
	sudo pip install oletools

	#RegRippy
	echo " >>>>>>  Installation de RegRippy "
	sudo pip install regrippy

	#SigmaHQ/sigma
	echo " >>>>>>  Installation de Sigma "
	sudo pip install ruamel.yaml
	sudo git clone $SIGMA
	echo "Sigma" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "-----" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "Generic Signature Format for SIEM Systems " | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	#Récupération Github Volatility3
	echo " >>>>>>  Installation de Volatility3 "
	sudo git clone $VOLATILITY3

	#Zircolite
	echo " >>>>>>  Installation de Zircolite "
	sudo /usr/bin/python3 -m pip install --upgrade pip
	sudo pip3 install tqdm
	sudo git clone $ZIRCOLITE
	sudo pip3 install -r ./Zircolite/requirements.txt
	echo "Zircolite" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "---------" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "A standalone SIGMA-based detection tool for EVTX." | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt
	#Récupération de la documentation Zircolite
	sudo wget $ZIRCOLITE_DOC
	#Création des règles SIGMA dans le dossier Zircolite
	sudo ./sigma/tools/sigmac -t sqlite -c ./sigma/tools/config/generic/sysmon.yml -c ./sigma/tools/config/generic/powershell.yml -c ./sigma/tools/config/zircolite.yml -d ./sigma/rules/windows/ --output-fields title,id,description,author,tags,level,falsepositives,filename,status --output-format json -r -o ./Zircolite/rules_sysmon.json --backend-option table=logs
	sudo ./sigma/tools/sigmac -t sqlite -c ./sigma/tools/config/generic/windows-audit.yml -c ./sigma/tools/config/generic/powershell.yml -c ./sigma/tools/config/zircolite.yml -d ./sigma/rules/windows/ --output-fields title,id,description,author,tags,level,falsepositives,filename,status --output-format json -r -o ./Zircolite/rules_generic.json --backend-option table=logs

	#Fenrir
	echo " >>>>>>  Installation de Fenrir "
	sudo git clone $FENRIR
	echo "Fenrir" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "------" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "Simple Bash IOC Scanner" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	#Loki
	echo " >>>>>>  Installation de Loki "
	sudo git clone $LOKI
	sudo pip3 install -r ./Loki/requirements.txt
	cd Loki
	echo " >>>>>>  Mise en place des signatures pour Loki "
	sudo git clone $LOKI_SIGNATURE
	cd ..
	echo "Loki" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "----" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "Simple IOC and Incident Response Scanner" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	echo "---------------------------------------------------------------------"
	echo "OUTILS INDEPENDANTS INSTALLES"
	echo "---------------------------------------------------------------------"
}

Etape60_install_guest_additions(){
	echo "---------------------------------------------------------------------"
	echo "Début de l'installation des GUEST ADDITIONNAL TOOLS"
	echo "---------------------------------------------------------------------"

	echo "Création du répertoire /media/cdrom"
	sudo mkdir -p /media/cdrom

	echo "Montage du fichier VBoxGuestAdditions.iso"
	sudo mount -t auto /home/analyste/VBoxGuestAdditions.iso /media/cdrom

	echo "Copie de VBoxLinuxAdditions.run	dans /tmp"
	sudo cp /media/cdrom/VBoxLinuxAdditions.run	/tmp/VBoxLinuxAdditions.run

	echo "Modification des droits de /tmp/VBoxLinuxAdditions.run"
	sudo chmod +x /tmp/VBoxLinuxAdditions.run

	echo "Exécution de /tmp/VBoxLinuxAdditions.run"
	sudo /tmp/VBoxLinuxAdditions.run

	echo "---------------------------------------------------------------------"
	echo "GUEST ADDITIONNAL TOOLS INSTALLES"
	echo "---------------------------------------------------------------------"
}

Etape10_disableautomaticupdate
Etape20_upgrade
Etape30_install_sift
Etape40_install_packaged_tools
Etape50_install_unpacked_tools
Etape60_install_guest_additions
