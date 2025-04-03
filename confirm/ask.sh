#!/bin/bash

read -p "Are you sure you want to proceed? (y/n): " confirm
if [[ "$confirm" == "y" ]]; then
  echo "yes"
else
  echo "no"
fi
