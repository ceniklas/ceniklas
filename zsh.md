
brew install cowsay (VERY IMPORTANT 😁)

Add to ~/.zshrc

function executeorder66 () {
    echo 'Wipe them out.'
    git fetch -p && for x in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); do git branch -D $x; done
    cowsay -f vader "Yes my master"
}
