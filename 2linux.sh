#!/bin/bash
#execute dos2unix
find . -name "*.yaml" -exec dos2unix {} \;
find . -name "*.sh" -exec dos2unix {} \;
dos2unix .env