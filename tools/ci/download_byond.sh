#!/bin/bash
set -e
source dependencies.sh
echo "Downloading BYOND version $BYOND_MAJOR.$BYOND_MINOR"
curl "https://secure.byond.com/download/build/516/516.1658_byond.zip" -o C:/byond.zip -A "The-Final-Nights/2.0 Continuous Integration"
