#!/usr/bin/env bash

rm -rf public/*

cp -R functions/nuxt/dist/client public/assets

cp -R static/* public
