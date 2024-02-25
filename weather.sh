#!/usr/bin/env bash
# Check the weather for a given location
# This is bad. There are probably multiple ways to break this

read -p "City: " city
curl "https://wttr.in/${city// /-}"