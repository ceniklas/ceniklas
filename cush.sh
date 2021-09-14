touch ~/.cush.function
echo 'branch=$(git branch --show-current)
if [[ $branch == "master" ]];
then
  cowsay -s -f tux "No, you are on master."
else
  git commit -m "WIP $(curl -s http://whatthecommit.com/index.txt)" --no-verify && git push -u origin HEAD --no-verify
  cowsay -s -f head-in "Oh ya..."
fi
' > ~/.cush.function
chmod +x ~/.cush.function


# branch=$(git branch --show-current)
# if [[ $branch == "master" ]];
# then
#   cowsay -s -f tux "No, you're on master."
# else
#   git commit -m "WIP $(curl -s http://whatthecommit.com/index.txt)" --no-verify && git push -u origin HEAD --no-verify
#   cowsay -s -f head-in "Oh ya..."
# fi