#!/bin/bash
packages_depot=(
 "docker.io"
 "build-essential"
 "pff-tools"
 "binwalk"
 "mariadb-server"
 "libdistorm3-dev"
 "yara"
 "libraw1394-11"
 "libcapstone-dev"
 "capstone-tool"
 "tzdata"
 "python2"
 "python2.7-dev"
 "libpython2-dev"
)

CAST="https://github.com/ekristen/cast/releases/download/v0.14.24/cast-v0.14.24-linux-amd64.deb"

CAPA="https://github.com/mandiant/capa/releases/download/v4.0.1/capa-v4.0.1-linux.zip"
DUMPZILLA="http://www.dumpzilla.org/dumpzilla.py"
FENRIR="https://github.com/Neo23x0/Fenrir"
FLOSS="https://github.com/fireeye/flare-floss/releases/download/v1.7.0/floss-v1.7.0-linux.zip"
LOKI="https://github.com/Neo23x0/Loki"
LOKI_SIGNATURE="https://github.com/Neo23x0/signature-base"
SIGMA="https://github.com/SigmaHQ/sigma"
VOLATILITY3="https://github.com/volatilityfoundation/volatility3.git"
VOLATILITY3_SYMBOL="https://github.com/JPCERTCC/Windows-Symbol-Tables.git"
ZIRCOLITE="https://github.com/wagga40/Zircolite"
ZIRCOLITE_DOC="https://github.com/wagga40/Zircolite/raw/master/docs/Zircolite_manual.pdf"
ZUI="https://github.com/brimdata/zui/releases/download/v1.6.0/zui_1.6.0_amd64.deb"

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

Etape30_install_cast(){
	echo "---------------------------------------------------------------------"
	echo "Installation de CAST"
	echo "---------------------------------------------------------------------"

	sudo wget $CAST --quiet
	CAST_file=$(echo $CAST | rev |cut -d'/' -f1 | rev)
    echo $CAST_file " téléchargé"
	sudo dpkg -i $CAST_file
	sudo rm -f $CAST_file

    echo $CAST_file " installé"
}

Etape31_install_sift(){
	echo "---------------------------------------------------------------------"
	echo "Début de l'installation de SIFT"
	echo "---------------------------------------------------------------------"

	sudo cast install teamdfir/sift-saltstack

	echo "SIFT installée"
}

Etape32_install_remnux(){
	echo "---------------------------------------------------------------------"
	echo "Début de l'installation de REMNUX"
	echo "---------------------------------------------------------------------"

	sudo cast install remnux/salt-states

	echo "REMNUX installée"
}

Etape40_install_packaged_tools(){
	echo "---------------------------------------------------------------------"
	echo "Début de l'installation des PACKAGES SUPPLEMENTAIRES"
	echo "---------------------------------------------------------------------"

	for package in "${packages_depot[@]}"
	do
		echo "---------------------------------------------------------------------"
		echo "Installation du package $package"
		echo "---------------------------------------------------------------------"		
		sudo apt install -y $package
		if [ $? -ne 0 ]; then
			echo "*********************************************************************"
			echo "************** IMPOSSIBLE D'INSTALLER LE PACKAGE $package ***********"
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
	ln -s /TOOLS $(pwd)/Bureau/Outils

	#Dumpzilla
	echo " >>>>>>  Installation de Dumpzilla "
	cd /TOOLS
	sudo wget $DUMPZILLA --quiet
	arrDUMP=(${DUMPZILLA//// })
	sudo chmod +x ${arrDUMP[-1]}
	echo "DUMPZILLA" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "---------" | sudo tee -a /TOOLS/README_for_tools.txt
    echo "extract all forensic interesting information of Firefox, Iceweasel and Seamonkey browsers to be analyzed" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	#Fenrir
	echo " >>>>>>  Installation de Fenrir "
	cd /TOOLS
	sudo git clone $FENRIR
	echo "Fenrir" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "------" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "Simple Bash IOC Scanner" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	#Loki
	echo " >>>>>>  Installation de Loki "
	cd /TOOLS
	sudo git clone $LOKI
	sudo pip3 install -r ./Loki/requirements.txt
	cd Loki
	sudo chmod +x loki.py
	echo " >>>>>>  Mise en place des signatures pour Loki "
	sudo git clone $LOKI_SIGNATURE
	sudo python3 loki-upgrader.py
	cd ..
	echo "Loki" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "----" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "Simple IOC and Incident Response Scanner" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	#RegRippy
	echo " >>>>>>  Installation de RegRippy "
	cd /TOOLS
	sudo pip3 install regrippy --quiet

	#SigmaHQ/sigma
	echo " >>>>>>  Installation de Sigma "
	cd /TOOLS
	sudo pip3 install ruamel.yaml --quiet
	sudo git clone $SIGMA
	echo "Sigma" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "-----" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "Generic Signature Format for SIEM Systems " | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	#Volatility2
	echo " >>>>>>  Installation de Volatility2 "
	cd
	curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
	sudo python2 get-pip.py
	rm -f get-pip.py
	sudo python2 -m pip install -U setuptools wheel
	python2 -m pip install -U distorm3 yara pycrypto pillow openpyxl ujson pytz ipython capstone
	sudo python2 -m pip install yara
	sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/lib/libyara.so
	python2 -m pip install -U git+https://github.com/volatilityfoundation/volatility.git
	sudo ln -s $(pwd)/.local/bin/vol.py /usr/bin/vol.py

	#Récupération Github Volatility3
	echo " >>>>>>  Installation de Volatility3 "
	cd /TOOLS
	sudo git clone $VOLATILITY3
	echo "Volatility3" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "-----------" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "The volatile memory extraction framework " | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

	#Ajout de symboles pour volatility3
	sudo git clone $VOLATILITY3_SYMBOL
	sudo mv Windows-Symbol-Tables/symbols/windows volatility3/volatility3/symbols
	sudo rm -rf Windows-Symbol-Tables

	#Zircolite
	echo " >>>>>>  Installation de Zircolite "
	cd /TOOLS
	sudo /usr/bin/python3 -m pip install --upgrade pip
	sudo pip3 install tqdm --quiet
	sudo git clone $ZIRCOLITE
	sudo pip3 install -r ./Zircolite/requirements.txt
	echo "Zircolite" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "---------" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "A standalone SIGMA-based detection tool for EVTX." | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt
	#Récupération de la documentation Zircolite
	sudo wget $ZIRCOLITE_DOC --quiet
	#Création des règles SIGMA dans le dossier Zircolite
#	sudo ./sigma/tools/sigmac -t sqlite -c ./sigma/tools/config/generic/sysmon.yml -c ./sigma/tools/config/generic/powershell.yml -c ./sigma/tools/config/zircolite.yml -d ./sigma/rules/windows/ --output-fields title,id,description,author,tags,level,falsepositives,filename,status --output-format json -r -o ./Zircolite/rules_sysmon.json --backend-option table=logs
#	sudo ./sigma/tools/sigmac -t sqlite -c ./sigma/tools/config/generic/windows-audit.yml -c ./sigma/tools/config/generic/powershell.yml -c ./sigma/tools/config/zircolite.yml -d ./sigma/rules/windows/ --output-fields title,id,description,author,tags,level,falsepositives,filename,status --output-format json -r -o ./Zircolite/rules_generic.json --backend-option table=logs

	#Zui
	echo " >>>>>>  Installation de Zui "
	sudo wget $ZUI --quiet
	ZUI_file=$(echo $ZUI |rev | cut -d'/' -f1 |rev)
	sudo dpkg -i $ZUI_file
	sudo rm -f $ZUI_file

	#Docker Splunk
	echo " >>>>>>  Récupération du docker SPLUNK "
	sudo docker pull splunk/splunk --quiet
	echo "Docker Splunk" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "-------------" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "The software lets you collect, analyze, and act upon the untapped value of big data that your technology infrastructure, security systems, and business applications generate." | sudo tee -a /TOOLS/README_for_tools.txt
	echo 'docker run -d -p 8000:8000 -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=password" --name splunk splunk/splunk:latest' | sudo tee -a /TOOLS/README_for_tools.txt
	echo "      Mot de passe : password / Port d'écoute : 8000" | sudo tee -a /TOOLS/README_for_tools.txt	
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt
	
	#Docker Suricata
	echo " >>>>>>  Récupération du docker SURICATA "
	sudo docker pull jasonish/suricata --quiet
	echo "Docker Suricata" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "---------------" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "Suricata is a high performance, open source network analysis and threat detection software used by most private and public organizations, and embedded by major vendors to protect their assets." | sudo tee -a /TOOLS/README_for_tools.txt
	echo "LIVE : docker run --rm -it --net=host --cap-add=net_admin --cap-add=net_raw --cap-add=sys_nice -v $(pwd)/logs:/var/log/suricata jasonish/suricata:latest -i <interface>"  | sudo tee -a /TOOLS/README_for_tools.txt
	echo "" | sudo tee -a /TOOLS/README_for_tools.txt

    #Docker Zircolite
	echo " >>>>>>  Récupération du docker ZIRCOLITE "
    sudo docker pull wagga40/zircolite --quiet
    echo "Docker Zircolite" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "----------------" | sudo tee -a /TOOLS/README_for_tools.txt
	echo "Use in case of Azeroth" | sudo tee -a /TOOLS/README_for_tools.txt
	echo 'docker run --rm --tty -v EVTX_DIR:/case/input:ro -v OUTPUT_DIR:/case/output wagga40/zircolite --ruleset rules/rules_windows_generic_full.json --evtx /case/input -o /case/output/OUTPUT_FILE.json")' | sudo tee -a /TOOLS/README_for_tools.txt
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
	sudo mount -t auto /home/$USER/VBoxGuestAdditions.iso /media/cdrom

	echo "Copie de VBoxLinuxAdditions.run	dans /tmp"
	sudo cp /media/cdrom/VBoxLinuxAdditions.run	/tmp/VBoxLinuxAdditions.run

	echo "Modification des droits de /tmp/VBoxLinuxAdditions.run"
	sudo chmod +x /tmp/VBoxLinuxAdditions.run

	echo "Exécution de /tmp/VBoxLinuxAdditions.run"
	sudo /tmp/VBoxLinuxAdditions.run

	echo "---------------------------------------------------------------------"
	echo "GUEST ADDITIONNAL TOOLS INSTALLES"
	echo "---------------------------------------------------------------------"
	
	echo "Ajout de l'utilisateur au groupe vboxsf pour accéder au partage"
	sudo adduser $USER vboxsf
}

sleep 40 
Etape10_disableautomaticupdate
Etape20_upgrade
Etape30_install_cast
Etape31_install_sift
###Etape32_install_remnux
Etape40_install_packaged_tools
Etape50_install_unpacked_tools
Etape60_install_guest_additions
