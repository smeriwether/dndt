#!/bin/bash

set -e

echo "Deleting node modules..."
rm -rf ./node_modules
echo "Finished deleting node modules"

echo "Making tmp directory..."
mkdir ../tmp-deploy
echo "Finished making tmp directory"

echo "Copying files over..."
cp -R . ../tmp-deploy
echo "Finished copying over files"

echo "Deleting git directory..."
rm -rf ../tmp-deploy/.git
echo "Finished deleting git directory"

echo "Adding back node modules..."
npm install
echo "Finished adding back node modules"

echo "Sending files to remote directory..."
scp -r ../tmp-deploy/ root@147.182.174.243:/app/datenightdinnertime
echo "Finished sending files to remote directory"

echo "Deleting tmp directory..."
rm -rf ../tmp-deploy
echo "Finished deleting tmp directory"

echo "Configuring nginx..."
scp nginx.conf root@147.182.174.243:/etc/nginx/sites-enabled/datenightdinnertime.com
ssh root@147.182.174.243 "/etc/init.d/nginx reload"
echo "Finished configuring nginx"
