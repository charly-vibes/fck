#!/bin/bash
rsync -av --delete ./dist/ server:/var/www/app/
