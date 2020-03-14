#!/bin/sh
#130320
version=20.03
baseversion=20.03+0

newversion=20.03+0

branch1=
branch2=
mv a32pup-${version}.iso Arch32Pup-${newversion}${branch2}.iso
mv a32pup-${version}.iso.md5.txt Arch32Pup-${newversion}${branch2}.iso.md5.txt
mv a32pup-${version}.iso.sha256.txt Arch32Pup-${newversion}${branch2}.iso.sha256.txt
sed -i "s/a32pup/Arch32Pup/" Arch32Pup-${newversion}${branch2}.iso.md5.txt
sed -i "s/${version}/${newversion}${branch2}/" Arch32Pup-${newversion}${branch2}.iso.md5.txt

echo "Making delta Arch32Pup-${baseversion}${branch1}.iso___Arch32Pup-${newversion}${branch2}.iso.delta"
xdelta3 -e -s "Arch32Pup-${baseversion}${branch1}.iso" "Arch32Pup-${newversion}${branch2}.iso" "Arch32Pup-${baseversion}${branch1}.iso___Arch32Pup-${newversion}${branch2}.iso.delta"

exit

echo "Making delta Arch32Pup-${newversion}${branch2}.iso___Arch32Pup-${baseversion}${branch1}.iso.delta"
xdelta3 -e -s "Arch32Pup-${newversion}${branch2}.iso" "Arch32Pup-${baseversion}${branch1}.iso" "Arch32Pup-${newversion}${branch2}.iso___Arch32Pup-${baseversion}${branch1}.iso.delta"
