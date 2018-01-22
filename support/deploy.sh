#!/bin/sh
jekyll build && netlify deploy && aws s3 sync --profile koenighotze _site/ s3://koenighotze.de --acl public-read --region eu-central-1
