#!/bin/bash

pipenv install

cd terraform
terraform init
cd -

