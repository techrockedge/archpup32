# ArchPup32
ArchPup32 Puppy Linux woof-CE development sector

On a modern 32-bit version of Puppy with devx installed:

**Step #1 woof-CE initialization**
In a Linux filesystem....

Run in a terminal:

  git clone https://github.com/puppylinux-woof-CE/woof-CE.git -b testing

Go to the resulting woof-CE folder and run in a terminal:

  ./merge2out

with parameters:
-2 (x86)
-2 (slackware)
-3 (14.2)

**Step #2 Patching merg2out output**

Go up a level and rename the woof-out_x86_x86_slackware_14.2 folder to something shorter like woof-out_arch32

Delete the following from woof-out_arch32
-packages-pet
-packages-tgz_txz-14.2
-DISTRO_PKGS_SPECS-slackware-14.2

**Step #2A (Option - A) - Use a Tarball to replace/add key files**

Optionally Generate tarball using the script, "mk_tarball.sh" or alternatively grap a prebuilt tarball.

Put the tarball into the same folder as woof-out_arch32

Click on the tarball and extract all components into woof-out_arch32

**Step #2A (Option - B) - use the mk_tarball.sh to copy files into woof-out_arch32**

On line#3 of mk_tarball.sh change out_type=file to out_type=directory
On line#6 modify the value of OUT_FILE to point to the woof-out_arch32 directory. 
e.g. OUT_FILE=/mnt/home/git_projects/woof-CE/woof-out_arch32
run the script mk_tarball.sh

**Step #3 -- Running woof-CE**

Go into woof-out_arch32

In a terminal run:
  ./0setup
  ./1download
  ./2createpackages
  ./3builddistro

When the iso is complete go into woof-output-a32pup-20.03

and in a terminal run:
  ./iso-rename.sh
