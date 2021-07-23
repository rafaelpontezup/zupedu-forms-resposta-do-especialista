##
# Inspired by https://gist.github.com/hugorodgerbrown/5317616
# Pandoc Docker Image: https://github.com/jagregory/pandoc-docker
# Pandoc demos: https://pandoc.org/demos.html
# Pandoc manual: https://pandoc.org/MANUAL.html
#

mkdir docx 2> /dev/null

FILES=Formulario-*.md
#FILES=Formulario-010-*.md

count=1
for f in $FILES
do
  # extension="${f##*.}"
  filename="F5.$count.${f%.*}"
  echo "[+] Converting '$f' to '$filename.docx'"
  rm "$filename.docx" 2> /dev/null
  docker run -v `pwd`:/source jagregory/pandoc -s --highlight-style tango -f markdown -t docx "$f" -o docx/"$filename.docx"
  count=`expr $count + 1`
done