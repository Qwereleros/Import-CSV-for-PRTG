This script is an IMPORT-CSV script for PRTG. This script is for powershel 5.1+


First you need an CSV file with the headers Devicename IP Groupname


<img width="248" height="192" alt="afbeelding" src="https://github.com/user-attachments/assets/6fef0434-1da2-467c-b3ca-c2a7e8bff62e" />





What the script exactly does is it first asks you if : 
1 You want to make a new group 
2 choose an existing group 
3 Use the groups in de CSV file


############# Making a new group ############# If you choose to make an new group it wil asks you to type an groupname. If the groupname includes any special or if its empty it wil not make the group and the same for if there is an other group with the same name.

If you made the group the script wil check the CSV file for empty spaces. If there is no groupname or device name the device can't be made. This is because you can't make an device without an device name or groupname in PRTG. But because you made an new group .the groupname in the CSV file won't matter. You can make the device without an Ip/DNS.

The script will show you which devices are missing the devicename. Now the scrip will ask if you want to continue the script or if you first want to change your CSV file.

If you continue the devices without devicename wil be skipped.

The script will now ask how you want to add you're sensors: 1 No sensors 2 With an template 3 Only ping ( You need to change the script to make this work) 4 Or let the device use auto discovery

After choosing one of the 4 options All the Devices will be made.




############# Choosing an existing group ############# If you choose to use an existing group, the script will show you all your groups. Type in one of your groups.

After you choose your group, the script will check the CSV file for empty fields. If there is no group name or device name, the device cannot be created. This is because you cannot create a device without a device name or group name in PRTG.

But because you chose a group, the group name in the CSV file will not matter. You can create the device without an IP/DNS.

The script will show you which devices are missing the device name. Now the script will ask if you want to continue the script or if you want to change your CSV file first.

If you continue, the devices without a device name will be skipped.

The script will now ask how you want to add your sensors: No sensors With a template Only ping (you need to change the script to make this work) Let the device use auto‑discovery

After choosing one of the four options, all the devices will be created.




############# Use the groups from the CSV file ############# If you choose to use the group names from the CSV file, the script will check the CSV file for empty fields. If there is no group name or device name, the device cannot be created. This is because you cannot create a device without a device name or group name in PRTG.

You can create the device without an IP/DNS.

The script will show you which devices are missing the device name. Now the script will ask if you want to continue the script or if you want to change your CSV file first.

If you continue, the devices without a device name will be skipped.

The script will now ask how you want to add your sensors: No sensors With a template Only ping (you need to change the script to make this work) Let the device use auto‑discovery

After choosing one of the four options, all the devices will be created.
