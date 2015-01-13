#!/usr/bin/env bash

# change into the script's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR > /dev/null

# configuration
OUT=out
TMP=tmp

# create temporary directory
mkdir $TMP

# copy .git/ to temp
cp -r $OUT/.git $TMP/.git
cp $OUT/.gitignore $TMP/.gitignore

# clean out directory and regenerate thmls
rm -rf $OUT

mkdir $OUT
cp -r $TMP/.git $OUT/.git
cp $TMP/.gitignore $OUT/.gitignore

# generate static htmls
docpad generate --env static

# go to the out folder
pushd $OUT > /dev/null

rm -rf posts/
touch .nojekyll

# add and push to github pages
git add -A
git commit -m "`date`"
git push -f origin master

# change back to root dir
popd > /dev/null

# remove temp directory
rm -rf $TMP