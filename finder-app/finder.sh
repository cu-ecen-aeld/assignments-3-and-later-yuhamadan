#!/bin/sh

filesdir=$1
searchstr=$2

if [ -z $filesdir ]; then
    echo "Must provide 'filesdir' as first argument" 1>&2
    exit 1
fi

if [ -z $searchstr ]; then
    echo "Must provide 'searchstr' as second argument" 1>&2
    exit 1
fi

echo "filesdir: $filesdir";
echo "searchstr: $searchstr";

if [ ! -d $filesdir ]; then
  echo "filesdir: $filesdir is not a directory!";
  exit 1
fi

x=0
y=0
for ifile in $(find $filesdir -type f)
do
    # echo $ifile
    x=$(($x+1))
    # echo $x
    word_count=$(grep -o $searchstr $ifile | wc -l)
    y=$((y + word_count))
done
# echo $x
# echo $y
echo "The number of files are $x and the number of matching lines are $y"