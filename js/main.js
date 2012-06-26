var sp = getSpotifyApi(1);

exports.init = init;

function init() {
  var hashtag = document.getElementById('hashtag');
  var searchBtn = document.getElementById('search');
  var models = sp.require('sp://import/scripts/api/models');
  var views = sp.require('sp://import/scripts/api/views');
  
  var playlist = new models.Playlist();
  console.log("creating playlist");

  var status = document.getElementById('details');

  searchBtn.addEventListener('click', function() {
     

    var xhr = new XMLHttpRequest();
    var request = 'http://search.twitter.com/search.json?q=' + hashtag.value

    xhr.open('GET', request);

    xhr.onreadystatechange = function () {
        if (xhr.readyState != 4) return;
        var data = JSON.parse(xhr.responseText);
        if (data.results[0]) { 
          var tweet = data.results[0].text;

          var search = new models.Search(tweet.match(/(?=play:).+?(?=\s)/i)[0].substr(5));

          search.observe(models.EVENT.CHANGE, function() {
            if (search.tracks.length) {
              var track = search.tracks[0];
              playlist.add(track);
              if (!models.player.playing) {
                models.player.play(track, playlist);
              }
              status.innerHTML = track.name;
            }     
          });

          search.appendNext();
        }
        //console.log(data);
    }

      

    xhr.send(null);

    console.log("clicked");

  });

}