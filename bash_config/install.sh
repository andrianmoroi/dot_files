#!/bin/bash
echo "Configuring '.bashrc' file."

for f in ./scripts/*
do
	full_path=$(realpath "$f")

	if ! grep "source $full_path" ~/.bashrc > /dev/null; then
		echo "not found"
		echo "source $full_path" >> ~/.bashrc
	fi
done
