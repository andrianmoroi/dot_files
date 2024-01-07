#!/bin/bash
echo "Updating '.bashrc' file with latest configuration files."

for f in ./scripts/*
do
	full_path=$(realpath "$f")

	if ! grep "source $full_path" ~/.bashrc > /dev/null; then
		echo "Adding $f source file to the bashrc."
		echo "source $full_path" >> ~/.bashrc
	fi
done
