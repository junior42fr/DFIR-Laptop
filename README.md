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
You can change that easily before the execution by modifying last lines in "Ubuntu.json"
Be aware to modify "Forensic.sh" too (line : 	sudo mount -t auto /home/analyste/VBoxGuestAdditions.iso /media/cdrom)

You can change the default size (80Go) for the VM by modifying the file "Ubuntu.json" (line : "disk_size": "80000")
You can change the default RAM size (8Go) for the VM by modifying the file "Ubuntu.json" (line : "memory": "8192")
You can change the default number of cpus (4) for the VM by modifying the file "Ubuntu.json" (line : "cpus": "4")

KNOWN ISSUE
-----------
If the installation in Virtual Box freeze, you just have to launch the VBox - VM manager
