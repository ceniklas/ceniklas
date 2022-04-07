#!/bin/bash

touch ~/.executeorder66.function

executeorder66welcome='echo "Wipe them out. All of them."'
executeorder66git='git fetch -p && for x in $(git for-each-ref --format '\''%(refname) %(upstream:track)'\'' refs/heads | awk '\''$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'\''); do git branch -D $x; done'
executeorder66bye='cowsay -f vader "Yes master."'

echo $executeorder66welcome >~/.executeorder66.function
echo "\n" >>~/.executeorder66.function
echo $executeorder66git >>~/.executeorder66.function
echo "\n" >>~/.executeorder66.function
echo $executeorder66bye >>~/.executeorder66.function
echo "\n" >>~/.executeorder66.function

chmod +x ~/.executeorder66.function

profilefunction='function executeorder66 () { ~/.executeorder66.function }'

if [ -n "$($SHELL -c 'echo $ZSH_VERSION')" ]; then
  # assume Zsh
  if grep -Fq "$profilefunction" ~/.zshrc; then
    echo 'executeorder66 updated to latest and greatest!'
  else
    echo $profilefunction >>~/.zshrc
    echo 'executeorder66 installed!'
  fi
elif [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
  # assume Bash
  echo "\nBash is untested, but feel free to add\n\n    $profilefunction \n\nto ~/.bash_profile, ~/.bashrc or whatever you're using.\n"
fi

# function executeorder66 () {
#   echo 'Wipe them out.'
#   git fetch -p && for x in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); do git branch -D $x; done
#   cowsay -f vader "Yes my master"
# }
