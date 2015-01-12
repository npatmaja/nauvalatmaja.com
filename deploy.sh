#!/usr/bin/env bash

# change into the script's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR > /dev/null

OUT=out
TMP=tmp

mkdir $TMP

cp -r $OUT/.git $TMP/.git

rm -rf $OUT

mkdir $OUT
cp -r $TMP/.git $OUT/.git

# generate static htmls
docpad generate --env static

# go to the out folder
pushd $OUT > /dev/null

rm -rf posts/
touch .nojekyll

# add and push to github pages
git add -A --force
git commit -m "`date`"
git push -f origin master

# change back to root dir
popd > /dev/null

rm -rf $TMP