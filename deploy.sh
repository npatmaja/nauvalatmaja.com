#!/usr/bin/env bash

OUT=out

# generate static htmls
docpad generate --env static

# go to the out folder
pushd $OUT > /dev/null

# add and push to github pages
git add -A --force
git commit -m "`date`"
git push -f origin master

# change back to root dir
popd > /dev/null