#!/bin/bash
IN_FILE="$(realpath ./woof-CE-out-replace.lst)"
out_type=file
case "$out_type" in
directory)
  OUT_FILE=arch32_tarball4woof_ce-20200314
  mkdir -p "$OUT_FILE"
  ;;
*)
  OUT_FILE=arch32_tarball4woof_ce-20200314.tar.gz
  ;;
esac
CWD=$(realpath .)
delete_old=yes
OUT_FILE_PATH="$(realpath $OUT_FILE || echo "$OUT_FILE")"
if [ "$delete_old" = yes ]; then
  [ -f "$OUT_FILE_PATH" ] && rm "$OUT_FILE_PATH"
else
  [ -f "$OUT_FILE_PATH" ] && mv "$OUT_FILE_PATH" "$OUT_FILE_PATH_back$$"
fi  
case "$OUT_FILE_PATH" in
*.gz)
  PRE_OUT_FILE_PATH="${OUT_FILE_PATH%.gz}"
  ;;
esac
if [ ! -z "PRE_OUT_FILE_PATH" ]; then
	if [ "$delete_old" = yes ]; then
	  [ -f "$PRE_OUT_FILE_PATH" ] && rm "$PRE_OUT_FILE_PATH"
	else
	  [ -f "$PRE_OUT_FILE_PATH" ] && mv "$PRE_OUT_FILE_PATH" "$PRE_OUT_FILE_PATH_back$$"
	fi  
fi
function process_output(){
  local exit_fn2=$1
  #if [ "$exit_fn2" = no ]; then
	  while read -r a_file a_root rest; do
	    #read -r a_file a_root rest
	    cd "$CWD"
	    a_file="$(echo "$a_file" | sed -e 's%\(^['"'"']\|^["]\)%%' -e 's%\(['"'"']\|["]\)%%')"
	    [ -z "$a_root" ] && a_root=$CWD 
	    a_root="$(echo "$a_root" | sed -e 's%\(^['"'"']\|^["]\)%%' -e 's%\(['"'"']\|["]\)%%')" 
	    [ -z "$a_root" ] && a_root=$CWD    
	    #a_root="${aroot%/}/"
	    #[ "$a_file" = EOF ] && break
	    #[ -z "$a_file" ] && break
        a_file2="${a_file%/*}"
        a_file2="${a_file2%/}"	    
	    [ -z "$(find "$a_root" -wholename "$a_root/$a_file2")" ] && cd "$CWD" && continue
	    
	        cd $a_root || { cd "$CWD" && continue; }
		    if [ -d "$OUT_FILE_PATH" ]; then
		      
		      [ -e "./$a_file2" ] && echo "./$a_file2" | cpio -pdu "$OUT_FILE_PATH"
		      f_pattern=${a_file##*/}
		      [ -z "$f_pattern" ] && f_pattern='*'
		      if [ "$(expr index "$a_file" /)" -gt 0 ]; then
		        d_pattern=${a_file%%/*}
		      else
		        if [ -d "$f_pattern" ]; then
		          d_pattern="$f_pattern"
		          f_pattern='*'		        
		        else
		          d_pattern=''  
		        fi
		      fi
		      [ ! -f ./"$d_pattern/$f_pattern" ] && \
		        find ./"$d_pattern" -name "$f_pattern" | cpio -pdu "$OUT_FILE_PATH"
		      
		    else
		      #a_file="${a_file%/*}"
		      #a_file="${a_file%/}"
		      a_root="${a_root%/}"
		      case "OUT_FILE_PATH" in
		      *)
		         if [ -f "$PRE_OUT_FILE_PATH" ]; then		      
		           tar -r -f "$PRE_OUT_FILE_PATH" $a_file2
		         else
		           tar -cf "$PRE_OUT_FILE_PATH" $a_file2
		         fi
		         #find . -name "$a_file" | tar -czvf "$OUT_FILE_PATH"
		        ;;
		      esac
			fi
	    
	    
	  done	
	#fi
	#exit 0
}

while read -r line; do
  echo "$line '' '' ''"
done <$IN_FILE | process_output "$exit_fn"
case "$OUT_FILE_PATH" in
*.gz)
  #set +x
  gzip -c "$PRE_OUT_FILE_PATH" > "$OUT_FILE_PATH" && rm "$PRE_OUT_FILE_PATH"
  ;;
esac
