#!/usr/bin/env bash

mkdir build/

# build up our js
ember build

# now make it small(er)
uglifyjs app/application.js -mc > build/application.js

# now copy over the static stuff
cp app/*.html build/
cp -R app/css build/
cp -R app/img build/
