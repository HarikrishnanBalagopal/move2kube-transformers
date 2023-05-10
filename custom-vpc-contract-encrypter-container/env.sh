#!/bin/bash

#Script for creating encrypted env contract

# ENV="env.yaml"
CONTRACT_KEY="resources/ibmfinal.crt"
PASSWORD="$(openssl rand 32 | base64 -w0)"
ENCRYPTED_PASSWORD="$(echo -n "$PASSWORD" | base64 -d | openssl rsautl -encrypt -inkey $CONTRACT_KEY  -certin | base64 -w0)"
ENCRYPTED_ENV="$(echo -n "$PASSWORD" | base64 -d | openssl enc -aes-256-cbc -pbkdf2 -pass stdin -in "$ENV" | base64 -w0)"

echo "hyper-protect-basic.${ENCRYPTED_PASSWORD}.${ENCRYPTED_ENV}"