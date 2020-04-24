# Functions

This is the folder where the functions go.

Depending on the complexity of the module, it is recommended to subdivide them into subfolders.

The module will pick up all .ps1 files recursively

# TODO

# Informations
PartitionNumber | DriveLetter   | Offset    | Size  | Type
-|-|-|-|-
1               |U          | 1048576   | 32 GB     | FAT32 XINT13

## Verbose
---
```
Windows Boot Manager
--------------------

identifier              {9dea862c-5cdd-4e70-acc1-f32b344d4795}
description             Windows Boot Manager
locale                  en-US
inherit                 {7ea2e1ac-2e61-4728-aaa3-896d9d0a9f0e}
default                 {7619dcc9-fafe-11d9-b411-000476eba25f}
displayorder            {7619dcc9-fafe-11d9-b411-000476eba25f}
toolsdisplayorder       {b2721d73-1db4-4c62-bf78-c548a880142d}
timeout                 30

Windows Boot Loader
-------------------
identifier              {7619dcc9-fafe-11d9-b411-000476eba25f}
device                  ramdisk=[boot]\sources\boot.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}
path                    \windows\system32\boot\winload.exe
description             Windows Setup
locale                  en-US
inherit                 {6efb52bf-1766-41db-a6b3-0ee5eff72bd7}
osdevice                ramdisk=[boot]\sources\boot.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}
systemroot              \windows
bootmenupolicy          Standard
detecthal               Yes
winpe                   Yes
ems                     No

Windows Boot Manager
--------------------
identifier              {9dea862c-5cdd-4e70-acc1-f32b344d4795}
description             Windows Boot Manager
locale                  en-US
inherit                 {7ea2e1ac-2e61-4728-aaa3-896d9d0a9f0e}
default                 {7619dcc9-fafe-11d9-b411-000476eba25f}
displayorder            {7619dcc9-fafe-11d9-b411-000476eba25f}
toolsdisplayorder       {b2721d73-1db4-4c62-bf78-c548a880142d}
timeout                 30

Windows Boot Loader
-------------------
identifier              {7619dcc9-fafe-11d9-b411-000476eba25f}
device                  ramdisk=[boot]\sources\boot.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}
path                    \windows\system32\boot\winload.exe
description             Windows Setup
locale                  en-US
inherit                 {6efb52bf-1766-41db-a6b3-0ee5eff72bd7}
osdevice                ramdisk=[boot]\sources\boot.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}
systemroot              \windows
bootmenupolicy          Standard
detecthal               Yes
winpe                   Yes
ems                     No
```
## Non-Verbose
---
```
Windows Boot Manager
--------------------
identifier              {bootmgr}
description             Windows Boot Manager
locale                  en-US
inherit                 {globalsettings}
default                 {default}
displayorder            {default}
toolsdisplayorder       {memdiag}
timeout                 30

Windows Boot Loader
-------------------
identifier              {default}
device                  ramdisk=[boot]\sources\boot.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}
path                    \windows\system32\boot\winload.exe
description             Windows Setup
locale                  en-US
inherit                 {bootloadersettings}
osdevice                ramdisk=[boot]\sources\boot.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}
systemroot              \windows
bootmenupolicy          Standard
detecthal               Yes
winpe                   Yes
ems                     No
```