#!/bin/sh

curl https://repo.manjaro.org/mirrors.json 2>/dev/null | jq -r '.[] | select( .country == "Germany" ) | .url'
