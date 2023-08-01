#!/bin/sh

writefile=$1
writestr=$2

if [ -z $writefile ]; then
    echo "Must provide 'writefile' as first argument" 1>&2
    exit 1
fi

if [ -z $writestr ]; then
    echo "Must provide 'writestr' as second argument" 1>&2
    exit 1
fi

echo "writefile: $writefile";
echo "writestr: $writestr";

writedir=$(dirname $writefile)

mkdir -p $writedir
if [ $? -ne 0 ] ; then
    echo "mkdir -p failed!...exiting"
    exit 1
fi

echo $writestr > $writefile
if [ ! -f $writefile ]; then
    echo "failed to create writefile: $writefile...exiting"
    exit 1
fi