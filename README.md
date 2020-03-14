# ArchPup32
ArchPup32 Puppy Linux woof-CE development sector

On a modern 32-bit version of Puppy with devx installed:

In a Linux filesystem....

Run in a terminal:

  git clone https://github.com/puppylinux-woof-CE/woof-CE.git -b testing

Go to the resulting woof-CE folder and run in a terminal:

  ./merge2out

with parameters:
2 (x86)
2 (slackware)
3 (14.2)

Go up a level and rename the woof-out_x86_x86_slackware_14.2 folder to something shorter like woof-out_arch32

Delete the following from woof-out_arch32
packages-pet
packages-tgz_txz-14.2
DISTRO_PKGS_SPECS-slackware-14.2

Put the tarball into the same folder as woof-out_arch32

Click on the tarball and extract all components into woof-out_arch32

Go into woof-out_arch32

In a terminal run:
  ./0setup
  ./1download
  ./2createpackages
  ./3builddistro

When the iso is complete go into woof-output-a32pup-20.03

and in a terminal run:
  ./iso-rename.sh
