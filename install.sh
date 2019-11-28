#!/bin/bash

usage(){
  echo "Usage: $0 -[hcv]"
  echo
  echo "       -h, print this and quit"
  echo "       -c, clean non-tex file in tikz directory" 
  echo "       -v, be verbose"
}

OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "h?cv" opt; do
  case "$opt" in
  h|\?)
    usage
    exit 0
    ;;
  v)  verbose="-v"
    ;;
  c)  clean="yes"
    ;;
  esac
done

# First generate latex pictures
WD=$(pwd)
# cd common/tikz
# for texfile in $(find . -name "_*" -prune -o -name "*.tex" -print)
# do
#   WSD=$(pwd)
#   
#   dir=$(dirname $texfile)
#   cd $dir
#   [ ! -d build ] && mkdir build
#   [ ! -z "$clean" ] && find . -name "*.tex" -prune -o -type f -exec rm -rf $verbose {} \;
#   pdflatex -shell-escape --halt-on-error --interaction=batchmode --output-directory=build/ $(basename $texfile) > ./build/log
#   mv -f $verbose *.dpth *.log build/ 2>/dev/null
#   mv -u $verbose build/$(basename $texfile .tex).pdf all.pdf
#   echo "Generated " *.pdf " for folder $dir"
#   
#   cd $WSD
# done
# cd $WD

[ ! -z "$clean" ] && rm -r $verbose $HOME/texmf

# Then install symbolic links to all relevant files
n=0
cd contents/
for file in $(find . -type f -print -o -name 'tikz' -prune) $(find tikz -name "_*" -prune -o -name "*.pdf" -print)
do
  in=$(readlink -e $file)
  ext=${file##*.}
  path="$HOME/texmf"
  
  case "$ext" in
    "bib")  path="$path/bibtex/bib/kgd/" ;;
    "bst")  path="$path/bibtex/bst/kgd/" ;;
    "cls")  path="$path/tex/latex/base/" ;;
    "sty")  path="$path/tex/latex/kgd/" ;;
    
    "jpg")  path="$path/tex/latex/local/images/" ;;
    "pdf")  path="$path/tex/latex/local/images/" ;;
    "png")  path="$path/tex/latex/local/images/" ;;
    *) path="" ;;
  esac
  
  if [ ! -z "$path" ]
  then
    out="$path$file"
    path=$(dirname "$out")
    [ ! -d $path ] && mkdir -pv $path
    printf "[$ext] "
    if [ ! -f $out ]
    then
      printf "\033[32m"
      ln -svf $in $out
      n=$(($n + 1))
    else
      printf "\033[90mLink to '$out' already exists\n"
    fi
    printf "\033[0m"
  else
    printf "[ERR] Unmanaged extension type '$ext'. Please correct me\n"
  fi
done

if [ $n -gt 0 ]
then
  echo "Updating tex..."
  sudo -H mktexlsr
fi
