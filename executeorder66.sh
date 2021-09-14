touch ~/.executeorder66.function

executeorder66command='echo "Wipe them out."
git fetch -p && for x in $(git for-each-ref --format '\''%(refname) %(upstream:track)'\'' refs/heads | awk '\''$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'\''); do git branch -D $x; done
cowsay -f vader "Yes my master."' > ~/.executeorder66.function

echo $executeorder66command > ~/.executeorder66.function

chmod +x ~/.executeorder66.function

if grep -Fq "function executeorder66" ~/.zshrc
then
  echo 'executeorder66 updated to latest and greatest!'
else
  echo 'function executeorder66 () { ~/.executeorder66.function }' >> ~/.zshrc
  echo 'executeorder66 installed!'
fi
