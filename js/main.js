var sp = getSpotifyApi(1);

exports.init = init;

function init() {
  var models = sp.require('sp://import/scripts/api/models');
 
  var hashtag = document.getElementById('hashtag');
  var searchBtn = document.getElementById('search');
  var playlist = new models.Playlist();
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
              if (!models.player.playing)
                models.player.play(track, playlist, 0);
              status.innerHTML = track.name;
            }
            search.ignore(models.EVENT.CHANGE);     
          });

          search.appendNext();
        }
        //console.log(data);
        xhr.onreadystatechange = null;
    }

    xhr.send(null);

    console.log("clicked");

  });

}