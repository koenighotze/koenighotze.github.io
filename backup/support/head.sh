#!/bin/sh

REVISION=$(git rev-parse --short HEAD)
sed -i -e "s/<REVISION>/$REVISION/" _includes/footer.html
