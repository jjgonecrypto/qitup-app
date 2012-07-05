spotify-tweet-control
=====================

spotify app to control a playlist via a twitter hashtag


supported services
-----

* twitter


how it works
------ 

* upon submitting a search query, all services (currently only twitter) are searched for public statuses that match the search term.

* for every found status:

    * spotify is searched for the top matching track (from the supplied artist, if any)
    
    * if no track can be found, the request is ignored

    * otherwise the top track is added to the on-the-fly playlist
    
* the playlist starts playing as soon as the first track has been added 

* every 30s, the services will be polled. any new statuses that match will be appended to the current playlist. if not currently playing, the playlist will resume playing.


matchers
------ 

tweets can use any of the following syntax (where #hashtag is the search term - note, the hash `#` itself is not required)

* __TRACK__: keywords `play` OR `listen` OR `queue` OR `hear` followed by song names in double quotes ("song name")

    egs. 

        i want to hear "some song" today please! #hashtag

        hey #hashtag you should play "some song"

        queue "some song" at #hashtag 

* [optional] __ARTIST__: keywords `by` OR `band` OR `artist` followed by artist name in double quotes ("band name") 

    egs.

        play "some song" by "some artist" #hashtag

        can i hear "that awesome track" at #hashtag? artist "my favourite band"

        queue "that song" by "that band" now! #hashtag

    > using an __ARTIST__ selector will help better find a top track.  

* [optional] instead of double quotes, any of the above can use colon and dashes (do:some-thing).

    egs.

        play:some-song by:some-artist #hashtag

        can i hear:that-awesome-track, band:my-favourite-band at #hashtag


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


testing
----- 

1. ensure you have already run `npm install` 

1. run `cake test` in the root folder to start the unit test suite