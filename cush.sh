touch ~/.cush.function

echo 'branch=$(git branch --show-current)
if [ $branch = "master" ] || [ $branch = "main" ]
then
  cowsay -s -f tux "No, you are on $branch."
else
  git commit -m "WIP $(curl -s http://whatthecommit.com/index.txt)" --no-verify && git push -u origin HEAD --no-verify
  cowsay -s -f head-in "Oh ya..."
fi
' > ~/.cush.function

chmod +x ~/.cush.function

if grep -Fq "function cush" ~/.zshrc
then
  echo 'cush updated to latest and greatest!'
else
  echo 'function cush () { ~/.cush.function }' >> ~/.zshrc
  echo 'cush installed!'
fi
