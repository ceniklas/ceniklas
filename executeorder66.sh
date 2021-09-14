touch ~/.executeorder66.function

executeorder66welcome='echo "Wipe them out."'
executeorder66git='git fetch -p && for x in $(git for-each-ref --format '\''%(refname) %(upstream:track)'\'' refs/heads | awk '\''$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'\''); do git branch -D $x; done'
executeorder66bye='cowsay -f vader "Yes my master."'

echo $executeorder66welcome > ~/.executeorder66.function
echo "\n" >> ~/.executeorder66.function
echo $executeorder66git >> ~/.executeorder66.function
echo "\n" >> ~/.executeorder66.function
echo $executeorder66bye >> ~/.executeorder66.function
echo "\n" >> ~/.executeorder66.function

chmod +x ~/.executeorder66.function

if grep -Fq "function executeorder66" ~/.zshrc
then
  echo 'executeorder66 updated to latest and greatest!'
else
  echo 'function executeorder66 () { ~/.executeorder66.function }' >> ~/.zshrc
  echo 'executeorder66 installed!'
fi
