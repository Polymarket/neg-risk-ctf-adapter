#!/bin/bash

# string="Hello World"

to_lowercase() {
    string=$1
    # Extract first character
    firstChar=${string:0:1}

    # Convert to lower case
    firstCharLower=$(echo "$firstChar" | tr '[:upper:]' '[:lower:]')

    # Concatenate back with the rest of the string
    newString="$firstCharLower${string:1}"

    echo "$newString"
}

# Check if file path argument was provided
if [ -z "$1" ]; then
    echo "Please provide a file path argument."
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "File $1 not found."
    exit 1
fi

# Extract filename without extension
filename=$(basename -- "$1")
filename="${filename%.*}"

bytecode=$(jq -r '.bytecode.object' "$1")
abi=$(jq -r '.abi' "$1")
object=$(jq -n --arg bytecode "$bytecode" --argjson abi "$abi" '{abi: $abi, bytecode: $bytecode}')

HEADER_BLOCK="///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////"

contents="$HEADER_BLOCK\n"
contents+="// $filename\n"
contents+="$HEADER_BLOCK\n\n"
contents+="export const $(to_lowercase "$filename")Contract = "
contents+="$object as const;"

echo -e "$contents"
