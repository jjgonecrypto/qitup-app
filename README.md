spotify-tweet-control
=====================

spotify app to control a playlist via a twitter hashtag


currently
--------

plays the most recent track preceeded by `play:` within any tweet that has the search term. the tracks must use dashes or underscores instead of spaces. eg.

    i want to play:smells-like-teen-spirit #myhashtag 

or 

    play:where_is_my_mind #myhashtag 


installation
-------

1. [optional] enable the developer account on spotify (allows you to load js console, debug, etc.)

1. `mkdir ~/Spotify` (or under `My Documents\Spotify` in WinX)

1. `cd Spotify` 

1. `git clone ....`

1. inside the project root, run `npm install` to ensure you have the dependencies (if you don't have npm, then download and install the latest nodejs).

1. run `cake watch&` to start a background process to automatically convert `.coffee` to `.js` and `.styl` to `.css` whenver one of the source files is updated. 

running 
------ 

1. open spotify app 

1. search for `spotify:app:twimote` (loads the app)

1. enter in your search query and click "search". (note: hash `#` character is not required). lastest track should start to play.