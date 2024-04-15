# DFIR-Laptop
Installation des outils nécessaires à l'investigation numérique pour un PC portable isolé en Windows 10 ou 11.

Télécharger simplement le projet et lancer le script "Setup.bat"

REQUIREMENTS
------------
Vous devez avoir un PC en Windows 10 or 11. Winget doit être installé en version 1.7 minimum (winget --version)

INFORMATIONS
------------
Les identifiants pour la machine virtuelle (VirtualBox) sont "analyste/analyste".

Vous pouvez changer la taille par défaut (80Go) de la VM en modifiant le fichier "variables.pkrvars.hcl" (ligne : disk_size = "80000")

Vous pouvez changer la taille par défaut (8Go) de la RAM de la VM en modifiant le fichier "variables.pkrvars.hcl" (ligne : memory = "16384")

Vous pouvez changer le nombre de CPU par défaut (4) de la VM en modifiant le fichier "variables.pkrvars.hcl" (ligne : cpus = "2")

PROBLEME CONNU
--------------
Si l'installation de la machine virtuelle se bloque (sur un écran violet/mauve), vous devrez simplement démarrer "Virtual Box - Gestionnaire de Machines". Ceci débloque la situation.
