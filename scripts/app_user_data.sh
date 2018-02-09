#!/bin/bash
cd /home/ubuntu/app
export DB_HOST=mongodb://${priv}:27017
node app.js