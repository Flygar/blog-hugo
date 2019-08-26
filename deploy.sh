#!/bin/bash

echo -e "\033[0;32mFor blog-hugo...\033[0m"
# 
rm -rf public
# Add changes to git.
git add -A

# Commit changes.
msg="backup site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

git submodule add git@github.com:Flygar/flygar.github.io.git public
#---------------------------------------------------

echo -e "\033[0;32mFor flygar.github.io ....\033[0m"
# Build the project.
hugo -t maupassant # if using a theme, replace by `hugo -t <yourtheme>`

# Go To Public folder
cd public
# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back
cd ..