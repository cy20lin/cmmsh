#!/bin/bash

prefix="${1-/usr/local}"
mkdir -p "${prefix}"
cp "$( dirname "${BASH_SOURCE[0]}" )/bin" "${prefix}" -R
cp "$( dirname "${BASH_SOURCE[0]}" )/lib" "${prefix}" -R

