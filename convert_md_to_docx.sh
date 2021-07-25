#!/bin/bash

##
# Inspired by https://gist.github.com/hugorodgerbrown/5317616
# Pandoc Docker Image: https://github.com/jagregory/pandoc-docker
# Pandoc demos: https://pandoc.org/demos.html
# Pandoc manual: https://pandoc.org/MANUAL.html
# Pandoc Syntax Highlighting: https://www.garrickadenbuie.com/blog/pandoc-syntax-highlighting-examples/
#
# WARNING: 
# dont't allow git to replace LF by CRLF, otherwise the script will not run
#
# use this command to config your git:
# git config core.autocrlf false
#
# more details: https://pt.stackoverflow.com/questions/44373/aviso-git-lf-will-be-replaced-by-crlf
##

# creates the docx folder
mkdir docx 2> /dev/null

# which files to convert?
FILES=Formulario-*.md
#FILES=Formulario-010-*.md

count=1
for f in $FILES
do
  # extension="${f##*.}"
  filename="F5.$count.${f%.*}.docx"

  echo "[+] Converting '$f' to '$filename'"

  rm "$filename" 2> /dev/null
  docker run -v `pwd`:/source jagregory/pandoc -s --highlight-style tango -f markdown -t docx "$f" -o docx/"$filename"
  count=`expr $count + 1`
done