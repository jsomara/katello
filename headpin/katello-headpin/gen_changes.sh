#!/bin/bash
HEADPIN=$PWD
CHANGES_FILE="file_changes.txt"
BRANCH=$1
[ $# -eq 0 ] && { echo "Please specify a branch or tag; eg $0 master" ; exit 1; }

# Clear out the old things
rm $CHANGES_FILE
rm -rf src

# generate the new file
git diff $BRANCH --name-only | grep -v "katello.spec" | grep "^src/"   > $CHANGES_FILE

# Copy over the changes
cd ../..
while read change
do
    if [ -e "$change" ]
    then
        cp --parents $change $HEADPIN
    fi
done < $HEADPIN/$CHANGES_FILE
cd $HEADPIN

# copy katello scss files for stylin it up
mkdir -p app/stylesheets
cp -r ../../src/app/stylesheets/* app/stylesheets
cp -r ../../src/public/stylesheets/* src/public/stylesheets
cp -r ../../src/public/javascripts/* src/public/javascripts
cp ../../src/config/compass.yml src/config
cp ../../src/config/assets.yml src/config
