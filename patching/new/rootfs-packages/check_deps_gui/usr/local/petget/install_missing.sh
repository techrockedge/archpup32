#!/bin/bash
INSTALL_MODE='Step by step installation (classic mode)'
EXPORT_FNs=false #Setting this to true might provide a way of overriding the functions in the ppm gui.
USE_installmodes_sh=false
SKIP_installmodes_sh=false
[ -e "$1" ] && MISSING_ITEMS_FILE="$1"
[ ! -e "$MISSING_ITEMS_FILE" && MISSING_ITEMS_FILE=${MISSING_ITEMS_FILE:-/tmp/petget_proc/missinglibs.txt}
[ ! -e "$MISSING_ITEMS_FILE" && MISSING_ITEMS_FILE=${MISSING_ITEMS_FILE:-/tmp/petget_proc/petget_missingpkgs_patterns}

/tmp/petget_proc/missinglibs.txt

function echo_items(){
	#cat MISSING_ITEMS_FILE=/tmp/petget_proc/missinglibs.txt | tr [[:space:]] "\n"
	case "$MISSING_ITEMS_FILE" in
	*missinglibs.txt)
	  #cat /tmp/petget_proc/missinglibs.txt | tr [[:space:]] "\n"
	  cat "$MISSING_ITEMS_FILE" | tr [[:space:]] "\n"
	  ;;
	*petget_missingpkgs_patterns)
	  cat "$MISSING_ITEMS_FILE" | sed -e 's/^[|]//g' -e 's/[|]$//g' | cut -f1 -d '|'
	  ;;
	esac
}

rm /tmp/petget_proc/pkgs_to_install_s243a
rm /tmp/petget_proc/pkgs_to_install
#touch /root/.packages/skip_space_check
echo changed > /tmp/petget_proc/mode_changed 
touch /tmp/petget_proc/force_install
touch /root/.packages/skip_space_check
touch /tmp/petget_proc/manual_pkg_download

rm /tmp/petget_proc/pkgs_to_install


if [ ! -f /tmp/petget_proc/install_pets_quietly -a ! -f /tmp/petget_proc/download_only_pet_quietly \
	-a ! -f /tmp/petget_proc/download_pets_quietly ]; then
	echo ok
elif [ "$PREVPKG" != "" ]; then
	echo changed >> /tmp/petget_proc/mode_changed
fi
rm -f /tmp/petget_proc/*_pet{,s}_quietly
echo "" > /tmp/petget_proc/forced_install
touch /tmp/petget_proc/install_classic
echo 'wizard' > /var/local/petget/ppm_mode




#install_package () is taken from: https://github.com/puppylinux-woof-CE/woof-CE/blob/60d94862a3343bf0a062a0fcd0dd73475d6985ba/woof-code/rootfs-skeleton/usr/local/petget/installmodes.sh#L406
install_package () {
 #set -x
 [ "$(cat /tmp/petget_proc/pkgs_to_install)" = "" ] && exit 0
 cat /tmp/petget_proc/pkgs_to_install | tr ' ' '\n' > /tmp/petget_proc/pkgs_left_to_install
 rm -f /tmp/petget_proc/overall_package_status_log
 echo 0 > /tmp/petget_proc/petget/install_status_percent
 echo "$(gettext "Calculating total required space...")" > /tmp/petget_proc/petget/install_status
 [ ! -f /root/.packages/skip_space_check ] && check_total_size
 #status_bar_func & #-----------
 while IFS="|" read TREE1 REPO zz #TREE1|REPO
 do
   [ -z "$TREE1" ] && continue
   echo "$REPO" > /tmp/petget_proc/petget/current-repo-triad
   if [ -f /tmp/petget_proc/install_quietly ];then
    if [  "$(grep $TREE1 /root/.packages/user-installed-packages 2>/dev/null)" = "" \
     -a -f /tmp/petget_proc/install_pets_quietly ]; then
     if [ "$(cat /var/local/petget/nt_category 2>/dev/null)" = "true" ]; then
      /usr/local/petget/installpreview.sh
     else
	  rxvt -title "$VTTITLE... $(gettext 'Do NOT close')" \
	  -fn -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-*-* -bg black \
      -fg grey -geometry 80x5+50+50 -e /usr/local/petget/installpreview.sh
     fi
    else
     if [ "$(cat /var/local/petget/nt_category 2>/dev/null)" = "true" ]; then
      /usr/local/petget/installpreview.sh
     else
	  rxvt -title "$VTTITLE... $(gettext 'Do NOT close')" \
	  -fn -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-*-* -bg black \
      -fg grey -geometry 80x5+50+50 -e /usr/local/petget/installpreview.sh
     fi
    fi
   else
   
    /usr/local/petget/installpreview.sh
    if [ $? -eq 100 ] ; then
       exit
    fi
   fi
   /usr/local/petget/finduserinstalledpkgs.sh #s243a: is this necessary? 
   
   sed -i "/$TREE1/d" /tmp/petget_proc/pkgs_left_to_install
 done < /tmp/petget_proc/pkgs_to_install
 sync
 report_results
 clean_up
}
[ "$EXPORT_FNs" = true ] && export -f install_package

do_install() {
	# Exit if called spuriously
	[ "$TREE1" = "" ] && exit 0
	export ENTRY=$TREE1
	pkg_info
	#pkg_info="$(cat /tmp/petget_proc/pkgs_to_install | cut -d '|' -f1,4)"
	#pkgs_to_install set in the pkg_info function
	echo "pkgs_to_install=$(cat /tmp/petget_proc/pkgs_to_install)"
	mv /tmp/petget_proc/pkgs_to_install /tmp/petget_proc/pkgs_to_install_1_5_10_11
	cat /tmp/petget_proc/pkgs_to_install_1_5_10_11 | cut -d '|' -f1,4 > /tmp/petget_proc/pkgs_to_install
	echo "pkgs_to_install=$(cat /tmp/petget_proc/pkgs_to_install)"
	#-- Make sure that we have atleast one mode flag
	if [ ! -f /tmp/petget_proc/install_pets_quietly \
	  -a ! -f /tmp/petget_proc/download_only_pet_quietly \
	  -a ! -f /tmp/petget_proc/download_pets_quietly \
	  -a ! -f /tmp/petget_proc/install_classic ] ; then
		touch /tmp/petget_proc/install_classic #/tmp/petget_proc/install_pets_quietly
	fi
	#if [ "$(grep $TREE1 /root/.packages/user-installed-packages)" != "" ] ; then
	#	. /usr/lib/gtkdialog/box_yesno "$(gettext 'Package is already installed')" "$(gettext 'This package is already installed! ')" "$(gettext 'If you want to re-install it, first remove it and then install it again. To download only or use the step-by-step classic mode, select No and then change the Auto Install to another option.')" "$(gettext 'To Abort the process now select Yes.')"
	#	if [ "$EXIT" = "yes" ]; then
	#		exit 0
	#	else
	#		echo $TREE1 > /tmp/petget_proc/forced_install
	#	fi
	#fi
	#--
	if [ "$(cat /tmp/petget_proc/forced_install 2>/dev/null)" != "" ]; then
		touch /tmp/petget_proc/force_install
	else
		rm -f /tmp/petget_proc/force_install
	fi
	#cut -d"|" -f1,4 /tmp/petget_proc/pkgs_to_install > /tmp/petget_proc/pkgs_to_install_tmp
	#mv -f /tmp/petget_proc/pkgs_to_install_tmp /tmp/petget_proc/pkgs_to_install
	#if ! [ -f /tmp/petget_proc/force_install -a -f /tmp/petget_proc/install_pets_quietly ]; then
		#/usr/local/petget/installed_size_preview.sh "$NEWPACKAGE" ADD
		if [ "$USE_installmodes_sh" != false ]; then
		  /usr/local/petget/installmodes.sh "$INSTALL_MODE"
		elif [ "$SKIP_installmodes_sh" != false ]; then
	      install_package #This was taken from installmodes.sh
	    else
	      
	      
	      cat /tmp/petget_proc/pkgs_to_install | tr ' ' '\n' > /tmp/petget_proc/pkgs_left_to_install
	      mv /tmp/petget_proc/pkgs_to_install /tmp/petget_proc/pkgs_to_install_1_5
	      cat /tmp/petget_proc/pkgs_to_install_1_5 | cut -d '|' -f1 > /tmp/petget_proc/pkgs_to_install
	      echo "pkgs_to_install=$(cat /tmp/petget_proc/pkgs_to_install)"
	      
	      export TREE1=${TREE1%%|*}	  
	      #rm /tmp/petget_proc/install_quietly 
	      set +x
	      echo "/usr/local/petget/installpreview.sh"   
	      /usr/local/petget/installpreview.sh
	    fi
}

echo_pkg_info_fields_helper(){
  [ $# -gt 0 ] && TREE1=$1
  [ $# -gt 1 ] && TREE1="$TREE1|$2"
  local repo_triad
  local result
  if [ -f /tmp/petget_proc/petget/filterpkgs.results.post ]; then
    result="$(grep ^$TREE1 /tmp/petget_proc/petget/filterpkgs.results.post)"
  fi
  if [ -z $result ]; then
   	pkg=$(echo $TREE1 | cut -f1 -d '|' )
	#repo_triad=$(echo $TREE1 | cut -f2 -d)
	n_fields=$(echo "$TREE1" | awk -F "|" '{print NF}' | head -n 1)
	if [ $n_fields -gt 1 ]; then
	  repo_triad=$(echo "$TREE1" | awk -F "|" '{print $NF}' | head -n 1)
	elif [ -f /tmp/petget_proc/petget ]; then
	  repo_triad=$(cat /tmp/petget_proc/petget | head -n 1) 
	fi 
	result="$(grep -m1 ^$pkg /var/packages/Packages-$repo_triad | cut -f1,5,10,11)" 
  fi
  echo "$result"
}
echo_pkg_info_fields(){
  	echo_pkg_info_fields_helper
  	#TODO maybe look at all repos specified by the ppm or fallback repos. 
}
#Taken from: https://github.com/puppylinux-woof-CE/woof-CE/blob/60d94862a3343bf0a062a0fcd0dd73475d6985ba/woof-code/rootfs-skeleton/usr/local/petget/pkg_chooser.sh#L120
# but modified to not depend on filterpkgs.results.post
pkg_info() {
	# Exit if called spuriously
	[ "$TREE1" = "" ] && exit 0
	#NEWPACKAGE="$(grep ^$TREE1 /tmp/petget_proc/petget/filterpkgs.results.post)"
	pkg=$(echo $TREE1 | cut -f1 -d '|' )
	export ENTRY1=$pkg #used in findnames.sh
	/usr/local/petget/findnames.sh  #We can remove this if we generage filterpkgs.results.post another way. See: postfilterpkgs.sh and installpreview.sh
   # rm -f /tmp/petget_proc/overall_*
    #/usr/local/petget/installed_size_preview.sh "$TREE1" ADD
    #installpreview.sh
	repo_triad=$(echo $TREE1 | cut -f2 -d '|' )
	echo "$repo_triad" > /tmp/petget_proc/petget/current-repo-triad
	IFS="|" read PKG_NAME PKG_CAT PKG_DESC PKG_REPO < <(echo_pkg_info_fields  )
	(
		echo "Name    : $PKG_NAME"
		echo "Category: $PKG_CAT"
		echo "Desc    : $PKG_DESC"
		echo "Repo    : $repo_triad" #$PKG_REPO
	) > /tmp/petget_proc/petget/pgk_info
	echo "$PKG_NAME|$PKG_CAT|$PKG_DESC|$repo_triad" >> /tmp/petget_proc/pkgs_to_install
}

#Taken from: https://github.com/puppylinux-woof-CE/woof-CE/blob/60d94862a3343bf0a062a0fcd0dd73475d6985ba/woof-code/rootfs-skeleton/usr/local/petget/installmodes.sh#L12
clean_up () {
 if [ "$(ls /tmp/petget_proc/*_pet{,s}_quietly /tmp/petget_proc/install_classic 2>/dev/null |wc -l)" -eq 1 ]; then
  for MODE in $(ls /tmp/petget_proc/*_pet{,s}_quietly /tmp/petget_proc/install_classic)
  do
   mv $MODE $MODE.bak
  done
 fi
 mv /tmp/petget_proc/install_quietly /tmp/petget_proc/install_quietly.bak
 echo -n > /tmp/petget_proc/pkgs_to_install
 rm -f /tmp/petget_proc/{install,remove}{,_pets}_quietly 2>/dev/null
 rm -f /tmp/petget_proc/install_classic 2>/dev/null
 rm -f /tmp/petget_proc/download_pets_quietly 2>/dev/null
 rm -f /tmp/petget_proc/download_only_pet_quietly 2>/dev/null
 rm -f /tmp/petget_proc/pkgs_left_to_install 2>/dev/null
 rm -f /tmp/petget_proc/pkgs_to_install_done 2>/dev/null
 rm -f /tmp/petget_proc/overall_pkg_size* 2>/dev/null
 rm -f /tmp/petget_proc/overall_dependencies 2>/dev/null
 rm -f /tmp/petget_proc/mode_changed 2>/dev/null
 rm -f /tmp/petget_proc/force*_install 2>/dev/null
 rm -f /tmp/petget_proc/pkgs_to_install_done 2>/dev/null
 rm -f /tmp/petget_proc/pgks_really_installed 2>/dev/null
 rm -f /tmp/petget_proc/pgks_failed_to_install 2>/dev/null
 rm -f /tmp/petget_proc/overall_petget_missingpkgs_patterns.txt 2>/dev/null
 rm -f /tmp/petget_proc/overall_missing_libs.txt 2>/dev/null
 rm -f /tmp/petget_proc/overall_install_report 2>/dev/null
 rm -f /tmp/petget_proc/pkgs_to_install_bar 2>/dev/null
 rm -f /tmp/petget_proc/manual_pkg_download 2>/dev/null
 rm -f /tmp/petget_proc/ppm_reporting 2>/dev/null
 rm -f /tmp/petget_proc/pkgs_DL_BAD_LIST 2>/dev/null
 rm -rf /tmp/petget_proc/PPM_LOGs/ 2>/dev/null
 mv $MODE.bak $MODE
 mv /tmp/petget_proc/install_quietly.bak /tmp/petget_proc/install_quietly
}
[ "$EXPORT_FNs" = true ] && export -f clean_up
report_results () {
 # Info source files
 touch /tmp/petget_proc/ppm_reporting # progress bar flag
 /usr/local/petget/finduserinstalledpkgs.sh #make sure...
 sync
 rm -f /tmp/petget_proc/pgks_really_installed 2>/dev/null
 rm -f /tmp/petget_proc/pgks_failed_to_install 2>/dev/null
 for LINE in $(cat /tmp/petget_proc/pkgs_to_install_done  | cut -f 1 -d '|' | sort | uniq)
 do
  [ "$(echo $LINE)" = "" ] && continue
  if [ -f /tmp/petget_proc/download_pets_quietly -o -f /tmp/petget_proc/download_only_pet_quietly \
   -o -f /tmp/petget_proc/manual_pkg_download ];then
   if [ -f /root/.packages/download_path ];then
    . /root/.packages/download_path
    DOWN_PATH="$DL_PATH"
   else
    DOWN_PATH=$HOME
   fi
   PREVINST=''
   REALLY=$(ls "$DOWN_PATH" | grep $LINE)
   [ "$REALLY" -a "$(grep $LINE /tmp/petget_proc/pkgs_DL_BAD_LIST 2>/dev/null | sort | uniq )" != "" ] && \
    REALLY='' && PREVINST="$(gettext 'was previously downloaded')"
  else
   PREVINST=''
   REALLY=$(grep $LINE /tmp/petget_proc/petget/installedpkgs.results)
   [ "$(grep $LINE /tmp/petget_proc/pgks_failed_to_install_forced 2>/dev/null | sort | uniq )" != "" -o \
    "$(grep $LINE /tmp/petget_proc/pkgs_DL_BAD_LIST 2>/dev/null | sort | uniq )" != "" ] \
    && REALLY='' && PREVINST="$(gettext 'was already installed')"
  fi
  if [ "$REALLY" != "" ]; then
   echo $LINE >> /tmp/petget_proc/pgks_really_installed
  else
   echo $LINE $PREVINST >> /tmp/petget_proc/pgks_failed_to_install
  fi
 done
 rm -f /tmp/petget_proc/pgks_failed_to_install_forced

 [ -f /tmp/petget_proc/pgks_really_installed ] && INSTALLED_PGKS="$(</tmp/petget_proc/pgks_really_installed)" \
  || INSTALLED_PGKS=''
 [ -f /tmp/petget_proc/pgks_failed_to_install ] && FAILED_TO_INSTALL="$(</tmp/petget_proc/pgks_failed_to_install)" \
  || FAILED_TO_INSTALL=''
 #MISSING_PKGS=$(cat /tmp/petget_proc/overall_petget_missingpkgs_patterns.txt |sort|uniq )
 MISSING_LIBS=$(cat /tmp/petget_proc/overall_missing_libs.txt 2>/dev/null | tr ' ' '\n' | sort | uniq )
 NOT_IN_PATH_LIBS=$(cat /tmp/petget_proc/overall_missing_libs_hidden.txt 2>/dev/null | tr ' ' '\n' | sort | uniq )
 cat << EOF > /tmp/petget_proc/overall_install_report
Packages succesfully Installed or Downloaded 
$INSTALLED_PGKS

Packages that failed to be Installed or Downloaded, or were aborted be the user
$FAILED_TO_INSTALL

Missing Shared Libraries
$MISSING_LIBS

Existing Libraries that may be in a location other than /lib and /usr/lib
$NOT_IN_PATH_LIBS
EOF

 # Info window/dialogue (display and option to save "missing" info)
 if [ "$MISSING_LIBS" ];then
  MISSINGMSG1="<i><b>$(gettext 'These libraries are missing:')
${MISSING_LIBS}</b></i>"
  LM='  <hbox space-expand="true" space-fill="true">
    <hbox scrollable="true" hscrollbar-policy="2" vscrollbar-policy="2" space-expand="true" space-fill="true">
      <hbox space-expand="false" space-fill="false">
        <eventbox name="bg_report" space-expand="true" space-fill="true">
          <vbox margin="5" hscrollbar-policy="2" vscrollbar-policy="2" space-expand="true" space-fill="true">
            '"`/usr/lib/gtkdialog/xml_pixmap building_block.svg 32`"'
            <text angle="90" wrap="false" yalign="0" use-markup="true" space-expand="true" space-fill="true"><label>"<big><b><span color='"'#bbb'"'>'$(gettext 'Libs')'</span></b></big> "</label></text>
          </vbox>
        </eventbox>
      </hbox>
      <vbox scrollable="true" shadow-type="0" hscrollbar-policy="1" vscrollbar-policy="1" space-expand="true" space-fill="true">
        <text ypad="5" xpad="5" yalign="0" xalign="0" use-markup="true" space-expand="true" space-fill="true"><label>"'${MISSINGMSG1}'"</label></text>
      </vbox>
    </hbox>
  </hbox>'
 fi
 if [ "$NOT_IN_PATH_LIBS" ];then #100830
  MISSINGMSG1="<i><b>${MISSINGMSG1}</b></i>
 
$(gettext 'These needed libraries exist but are not in the library search path (it is assumed that a startup script in the package makes these libraries loadable by the application):')
<i><b>${NOT_IN_PATH_LIBS}</b></i>"
 fi

 if [ -s /tmp/petget_proc/petget-installed-pkgs-log ];then
  BUTTON_TRIM="<button><input file stock=\"gtk-execute\"></input><label>$(gettext 'Trim the fat')</label><action type=\"exit\">BUTTON_TRIM_FAT</action></button>"
 fi

 export REPORT_DIALOG='
 <window title="'$(gettext 'Package Manager')'" icon-name="gtk-about" default_height="550">
 <vbox>
  '"`/usr/lib/gtkdialog/xml_info fixed package_add.svg 60 " " "$(gettext "Package install/download report")"`"'
  <hbox space-expand="true" space-fill="true">
    <hbox scrollable="true" hscrollbar-policy="2" vscrollbar-policy="2" space-expand="true" space-fill="true">
      <hbox space-expand="false" space-fill="false">
        <eventbox name="bg_report" space-expand="true" space-fill="true">
          <vbox margin="5" hscrollbar-policy="2" vscrollbar-policy="2" space-expand="true" space-fill="true">
            '"`/usr/lib/gtkdialog/xml_pixmap dialog-complete.svg 32`"'
            <text angle="90" wrap="false" yalign="0" use-markup="true" space-expand="true" space-fill="true"><label>"<big><b><span color='"'#15BC15'"'>'$(gettext 'Success')'</span></b></big> "</label></text>
          </vbox>
        </eventbox>
      </hbox>
      <vbox scrollable="true" shadow-type="0" hscrollbar-policy="2" vscrollbar-policy="1" space-expand="true" space-fill="true">
        <text ypad="5" xpad="5" yalign="0" xalign="0" use-markup="true" space-expand="true" space-fill="true"><label>"<i><b>'${INSTALLED_PGKS}' </b></i>"</label></text>
      </vbox>
    </hbox>
  </hbox>

  <hbox space-expand="true" space-fill="true">
    <hbox scrollable="true" hscrollbar-policy="2" vscrollbar-policy="2" space-expand="true" space-fill="true">
      <hbox space-expand="false" space-fill="false">
        <eventbox name="bg_report" space-expand="true" space-fill="true">
          <vbox margin="5" hscrollbar-policy="2" vscrollbar-policy="2" space-expand="true" space-fill="true">
            '"`/usr/lib/gtkdialog/xml_pixmap dialog-error.svg 32`"'
            <text angle="90" wrap="false" yalign="0" use-markup="true" space-expand="true" space-fill="true"><label>"<big><b><span color='"'#DB1B1B'"'>'$(gettext 'Failed')'</span></b></big> "</label></text>
          </vbox>
        </eventbox>
      </hbox>
      <vbox scrollable="true" shadow-type="0" hscrollbar-policy="2" vscrollbar-policy="1" space-expand="true" space-fill="true">
        <text ypad="5" xpad="5" yalign="0" xalign="0" use-markup="true" space-expand="true" space-fill="true"><label>"<i><b>'${FAILED_TO_INSTALL}' </b></i>"</label></text>
      </vbox>
    </hbox>
  </hbox>

  '${LM}'

  <hbox space-expand="false" space-fill="false">
     <button ok></button>
     <button>
      <label>'$(gettext 'View details')'</label>
      <input file stock="gtk-dialog-info"></input>
      <action>defaulttextviewer /tmp/petget_proc/overall_install_report &</action>
     </button>
     '${BUTTON_TRIM}'
     '"`/usr/lib/gtkdialog/xml_scalegrip`"'
  </hbox>
 </vbox>
 </window>'
 RETPARAMS="`gtkdialog --center -p REPORT_DIALOG`"
 eval "$RETPARAMS"
 echo 100 > /tmp/petget_proc/petget/install_status_percent
 
  #trim the fat...
 if [ "$EXIT" = "BUTTON_TRIM_FAT" ];then
  INSTALLEDPKGNAMES="`cat /tmp/petget_proc/petget-installed-pkgs-log | cut -f 2 -d ' ' | tr '\n' ' '`"
  #101013 improvement suggested by L18L...
  CURRLOCALES="`locale -a | grep _ | cut -d '_' -f 1`"
  LISTLOCALES="`echo -e -n "en\n${CURRLOCALES}" | sort -u | tr -s '\n' | tr '\n' ',' | sed -e 's%,$%%'`"
  export PPM_TRIM_DIALOG="<window title=\"$(gettext 'Puppy Package Manager')\" icon-name=\"gtk-about\" resizable=\"false\">
  <vbox>
   <pixmap><input file>/usr/share/pixmaps/puppy/dialog-question.svg</input></pixmap>
   <text><label>$(gettext "You have chosen to 'trim the fat' of these installed packages:")</label></text>
   <text use-markup=\"true\"><label>\"<b>${INSTALLEDPKGNAMES}</b>\"</label></text>
   <frame Locale>
   <text><label>$(gettext 'Type the 2-letter country designations for the locales that you want to retain, separated by commas. Leave blank to retain all locale files (see /usr/share/locale for examples):')</label></text>
   <entry><default>${LISTLOCALES}</default><variable>ENTRY_LOCALE</variable></entry>
   </frame>
   <frame $(gettext 'Documentation')>
   <checkbox><default>true</default><label>$(gettext 'Tick this to delete documentation files')</label><variable>CHECK_DOCDEL</variable></checkbox>
   </frame>
   <frame $(gettext 'Development')>
   <checkbox><default>true</default><label>$(gettext 'Tick this to delete development files')</label><variable>CHECK_DEVDEL</variable></checkbox>
   <text><label>$(gettext '(only needed if these packages are required as dependencies when compiling another package from source code)')</label></text>
   </frame>
   <text><label>$(gettext "Click 'OK', or if you decide to chicken-out click 'Cancel':")</label></text>
   <hbox>
    <button ok></button>
    <button cancel></button>
   </hbox>
  </vbox>
  </window>"
  RETPARAMS="`gtkdialog -p PPM_TRIM_DIALOG`"
  eval "$RETPARAMS"
  [ "$EXIT" != "OK" ] && exit $EXITVAL
  if [ ! -f /tmp/petget_proc/install_quietly ]; then
   /usr/lib/gtkdialog/box_splash -text "$(gettext 'Please wait, trimming fat from packages...')" &
   X4PID=$!
  fi
  elPATTERN="`echo -n "$ENTRY_LOCALE" | tr ',' '\n' | sed -e 's%^%/%' -e 's%$%/%' | tr '\n' '|'`"
  for PKGNAME in $INSTALLEDPKGNAMES
  do
   (
   cat /root/.packages/${PKGNAME}.files |
   while read ONEFILE
   do
    [ ! -f "$ONEFILE" ] && echo "$ONEFILE" && continue
    [ -h "$ONEFILE" ] && echo "$ONEFILE" && continue
    #find out if this is an international language file...
    if [ "$ENTRY_LOCALE" != "" ];then
     if [ "`echo -n "$ONEFILE" | grep --extended-regexp '/locale/|/nls/|/i18n/' | grep -v -E "$elPATTERN"`" != "" ];then
      rm -f "$ONEFILE"
      continue
     fi
    fi
    #find out if this is a documentation file...
    if [ "$CHECK_DOCDEL" = "true" ];then
     if [ "`echo -n "$ONEFILE" | grep --extended-regexp '/man/|/doc/|/doc-base/|/docs/|/info/|/gtk-doc/|/faq/|/manual/|/examples/|/help/|/htdocs/'`" != "" ];then
      rm -f "$ONEFILE" 2>/dev/null
      continue
     fi
    fi
    #find out if this is development file...
    if [ "$CHECK_DEVDEL" = "true" ];then
     if [ "`echo -n "$ONEFILE" | grep --extended-regexp '/include/|/pkgconfig/|/aclocal|/cvs/|/svn/'`" != "" ];then
      rm -f "$ONEFILE" 2>/dev/null
      continue
     fi
     #all .a and .la files... and any stray .m4 files...
     if [ "`echo -n "$ONEBASE" | grep --extended-regexp '\.a$|\.la$|\.m4$'`" != "" ];then
      rm -f "$ONEFILE"
      continue
     fi
    fi
    echo "$ONEFILE"
   done
   ) > /tmp/petget_proc/petget_pkgfiles_temp
   mv -f /tmp/petget_proc/petget_pkgfiles_temp /root/.packages/${PKGNAME}.files
  done
  [ "$X4PID" ] && kill $X4PID
 fi
}
[ "$EXPORT_FNs" = true ] && export -f report_results
function split_on_so(){
  local str=$1
  local len=${#str}
  local len_m=$((len-1))
  local index
  local s1
  local s2
  local p1
  local p2
  #Some notes here in case there is a compelling reasone to use PCRE (Perl compatible regular expressions)
  #if type perl; then
  #   read -d '\n' s1 s2 < <(perl -pe 's/(^(?:(?![.]so[.]?).)+)(?:([.]so[.]?)(.*))?$/\1\n\3/') 
  #else
    #ind=$(expr index $str .so)
    len=${#str}    
    s1=${str%%.so*}
    p1=${#s1}
    #[ $ind -eq 0 ] && ind=$len
    #p1=$((ind-1))
    #s1=${str:0:$p1}
    if [ $p1 -lt $len ]; then
      p2=$((p1+3))
      if [ "${str:$p2:1}" = '.' ]; then
        p2=$((p2+1))
      fi
    else
      p2=len
    fi
    s2=${str:$p2}
  #fi 
  echo "$s1"
  echo "$s2"
}
function link_lib(){
  local lib_spec="$1" 
  local needed_lib="$(echo "$lib_spec" | cut -f1 -d '|' | sed -e 's/^[+]//')"
  local ONEFILE="$(echo "$lib_spec|" | cut -f2 -d '|')" #this is the executable which needs the lib 
  local pkg_specs="$2" #e.g. /var/packages/re2-1:20200303.files:14:/usr/lib/libre2.so.6.0.0
                       #Lib name follows last colon. Package list path is beforefirst colon. 
  local needed_lib_base="$(echo "$needed_lib" | sed -e 's/[.]so.*$/.so/')"
  local needed_ver="$(echo "$lib_specs" | sed -e 's/^.*[.]so//' -e 's/^[.]//')"
  [ -z "needed_ver" ] && needed_ver='0'
  pkg_specs="$(grep -rn /var/packages -e "$needed_lib_base" | grep .files)"
  echo $pkg_specs | \
    while read a_pkg_spec; do
      
      lib_to_link="$(echo "$a_pkg_spec" | sed -e 's/.*[.]files:\([0-9]*[:]\)\?//')"
      
      lib_fm_pkg="$(echo "$lib_to_link_base" | sed -e 's%.*/\([^/]*\)[.]files.*%\1%g')"
      needed_lib_path="/usr/lib/$needed_lib"
      [ ! -z "$needed_ver" ] && needed_lib_path="${needed_lib_path}.${needed_ver}"
      
      if [ ! -e "$needed_lib_path" ]; then
        ldconfig #We probably don't need ldconfig if we link to somewhere in LD LIBRARY_PATH
        #so maybe don't do a ldconfig here because it is slow. 
        if [ ! -z "$ONEFILE" ]; then
          ln -s "$lib_to_link" "$needed_lib_path"
          if [ ! -z "$(ldd "$ONEFILE" | grep "$needed_lib" | grep "not found")" ]; then
            rm "$needed_lib_path"
          else
            break
          fi
        else
            provided_lib0="$(cat /var/packages/Provides-* | grep ^"$lib_fm_pkg" | cut -f5 -d '|' sed 's/.\('$needed_lib'[^,|$]*\)/\1/g')"
              provided_ver_range="$(echo "$provided_lib0" | sed -e 's/^.*[.]so[=]//')"
			  if [ ! -z "$ver_range" ]; then
			    local provided_min_ver="$(echo "$ver_range" | cut -f1 -d '-')"
			    local provided_max_ver="$(echo "$ver_range" | cut -f2 -d '-')"
			    p_min_ver_ary=(${provided_min_ver//./})
   			    p_max_ver_ary=(${provided_max_ver//./})
   			    needed_ver_ary=(${needed_ver//./})
			    i=0
			    while [ $i -lt ${#needed_ver_ary[@]} ]; do
			      if [ $i -lt ${#p_min_ver_ary[@]} ]; then
			        [ ${p_min_ver_ary[$i]} -gt ${needed_ver[$i]} ] && break
			        [ ${p_max_ver_ary[$i]} -lt ${needed_ver[$i]} ] && break
			        [ ${needed_ver[$i]} -gt ${p_min_ver_ary[$i]} ] && \
			          ln -s "$lib_to_link" "$needed_lib_path" && break 2
			      else
			        ln -s "$lib_to_link" "$needed_lib_path" && break 2
			      fi
			      i=$((i+1))
			    done
			  else   
			    ln -s "$lib_to_link" "$needed_lib_path" && break
              fi          
               
          break
        fi
      fi
    done
  #if [ -z "$pkg_spec" ]; then
  #  pkg_specs="$(cat /var/packages/user-installed-packages /var/packages/woof-installed-packages | \
  #               grep "$need_lib")"
                 
  	
}

while read a_lib; do
  
  while read packages_db; do
        REPO_TRIAD=$(basename $packages_db)
        REPO_TRIAD=${REPO_TRIAD#Packages-} #todo MAYBE MAKE THIS MORE ROBUST   
    for mode in 1 2 3; do  
   
      case "$mode" in
      1)
        provides_db="$(echo "$packages_db" | sed 's/^Packages-/^Provides-/')"
        a_lib_base="$(echo "$a_lib" | sed -r 's/^(.*)([.]so)(.*)$/\1\2/')"
        matches="$(cut -f1,5 -d '|' "$provides_db" | grep -F $a_lib_base )"
        if [ ! -z "$matches" ]; then
          a_pkg="$(echo "$matches" | cut -f1 -d '|')"
          if [ -f /var/packages/$a_pkg.files ]; then
            link_lib $a_lib "$(grep -rn "/var/packages/$a_pkg.files" -e "$a_lib")"
            unset matches
            break 2
          else
            break
          fi
        fi
        
        ;;
        2)
          link_lib $a_lib
          ;;
      3) 
        pre_guess=$a_lib
        while [ 1 -eq 1 ]; do
          #guess="$(echo "$pre_guess" | sed 's/[.]so[.]/-/')"
          #guess="$(echo "$pre_guess" | sed 's/[.]so//')"
          #read -d '\n' s1 s2 < <(echo "$pre_guess" | sed 's%([[.]so)*([.]so[.]\?\|)\?%\1\n\3%')
          read -d '\n' s1 s2 < <(split_on_so "$pre_guess") 
          s1="$(echo $s1 | sed 's%\(.*[^0-9]\)\([.]\|[-]\|[_]\)\([0-9]*\)$%\1\\([.]\\|[-]\\|[_]\\)\\?\3%')"
          if [ ${#s2} -gt 0 ]; then
            s2="$(echo $s2 | sed 's%\([.]\|[-]\|[_]\)%\\([.]\\|[-]\\|[_]\\)%')"
            
            lp=${#s2}; lp=$((lp-1))
            if [[ ${s1:$lp} =~ [0-9] ]]; then
              ptrn="$s1"'\([.]\|[-]\|[_]\)'"$s2"
            else
              ptrn="$s1"'\([.]\|[-]\|[_]\)\?'"$s2"
            fi
          else
            ptrn="$s1"
          fi

          aliases="$(echo "$PKG_NAME_ALIASES" | sed 's/\([^.]\|^\)\(*\)/\1.*/' | tr " " "\n" | tr "," " " | grep '\(^\|,\| \)'"${ptrn}"'\(^\|,\| \)' | tr "\n" " ")"
          aliases="$ptrn $aliases"
          #for mode in 1 2 3 4; do
            for a_alias in $aliases; do

                matches="$(cut -f1,2 -d '|' $packages_db | grep "|${a_alias}$")"
                matches="$(echo "$matches" | grep -v "$(cut -f1,2 -d '|' /var/packages/user-installed-packages)" | \ grep -v "$(cut -f1,2 -d '|' /var/packages/woof-installed-packages)" | cut f1 -d '|' )"
                [ ! -z $matches ] && break 4

                matches="$(cut -f1 -d '|' $packages_db | grep "^${a_alias}")"
                matches="$(echo "$matches" | grep -v "$(cut -f1 -d '|' /var/packages/user-installed-packages)" | \
                 grep -v "$(cut -f1 -d '|' /var/packages/woof-installed-packages)" )"
                [ ! -z $matches ] && break 4                
              
              ptrn2="${a_alias#lib}"
              if [ "$a_alias" != "$ptrn2" ]; then
                matches="$(cut -f1 -d '|' $packages_db | grep "^${ptrn2}" | grep lib)" 
                matches="$(echo "$matches" | grep -v "$(cut -f1 -d '|' /var/packages/user-installed-packages)" | \
                 grep -v "$(cut -f1 -d '|' /var/packages/woof-installed-packages)" )"
                [ ! -z $matches ] && break 4
                 matches="$(cut -f1 -d '|' $packages_db | grep "^${ptrn2}")"
                matches="$(echo "$matches" | grep -v "$(cut -f1 -d '|' /var/packages/user-installed-packages)" | \
                 grep -v "$(cut -f1 -d '|' /var/packages/woof-installed-packages)" )"               
              fi
            done
          #done
          
          last_pre_guess="$pre_guess"
          pre_guess="$(echo "$pre_guess" | sed -r 's/(.*)(.so)(.*)[.][^.]*/\1\2\3/')"
          if [ "$pre_guess" = "$last_pre_guess" ]; then
            pre_guess="$(echo "$pre_guess" | sed 's/[0-9]*$//')"
            [ "$pre_guess" = "$last_pre_guess" ] && break          
          fi

        done     
        ;;
      esac

    done
  done < <(find /var/packages -name 'Packages-*')
  if [ ! -z "$matches" ]; then
	#pkgs_to_install_s243a is two fields like at: https://github.com/puppylinux-woof-CE/woof-CE/blob/60d94862a3343bf0a062a0fcd0dd73475d6985ba/woof-code/rootfs-skeleton/usr/local/petget/pkg_chooser.sh#L159
	echo "$matches" | cut -d '|' -f1 | \
	  sed -n -E '/^[[:space:]]*$/! {s%(.*)%\1|'$REPO_TRIAD'%;p}'  >> /tmp/petget_proc/pkgs_to_install_s243a
	break
  fi   
done < <( echo_items ) 

#MISSING_ITEMS_FILE=/tmp/petget_proc/missinglibs.txt

while IFS= read line|| [ -n "$line" ]; 
do     
  export TREE1=$line
  
  #echo $TREE1 > /tmp/petget_proc/forced_install
  do_install #Expects four fields
done < /tmp/petget_proc/pkgs_to_install_s243a


#export -f do_instal #pkg_info do_install change_mode
