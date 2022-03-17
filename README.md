# DFIR-Laptop
Installation of all the tools for a stand-alone DFIR laptop on Windows 10 or 11

Just download all files and folder in the project and click on "Setup.bat"

REQUIREMENTS
------------
You must have a Windows 10 or 11.
You must have a second partition named in D:

INFORMATION
-----------
The credential for the VM (in VirtualBox) are "analyste/analyste".
You can change that easily before the execution by modifing last lines in "Ubuntu.json"
Be aware to modify "Forensic.sh" too (line : 	sudo mount -t auto /home/analyste/VBoxGuestAdditions.iso /media/cdrom)
