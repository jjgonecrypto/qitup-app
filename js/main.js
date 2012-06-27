var sp = getSpotifyApi(1);

exports.init = init;

function init() {
  var models = sp.require('sp://import/scripts/api/models');
 
  var hashtag = document.getElementById('hashtag');
  var searchBtn = document.getElementById('search');
  var status = document.getElementById('details');

  searchBtn.addEventListener('click', function() {
    var playlist = new models.Playlist();
  
    var xhr = new XMLHttpRequest();
    var request = 'http://search.twitter.com/search.json?q=' + hashtag.value

    xhr.open('GET', request);

    xhr.onreadystatechange = function () {
      if (xhr.readyState != 4) return;

      var data = JSON.parse(xhr.responseText);
      var html = "";
      data.results.forEach(function(result) {
        var tweet = result.text;

        var search = new models.Search(tweet.match(/(?=play:).+?(?=\s)/i)[0].substr(5));

        search.observe(models.EVENT.CHANGE, function() {
          
          if (search.tracks.length) {
            var track = search.tracks[0];
            if (playlist.indexOf(track) >= 0) return;
            playlist.add(track);
            if (playlist.length == 1)
              models.player.play(track, playlist, 0);
            html += "<li><strong>" + track.name + "</strong> by " + track.artists[0].name + " (@" + result.from_user + ")</li>";
          }
          status.innerHTML = "<ul>" + html + "</ul>";
          search.ignore(models.EVENT.CHANGE);     
        });

        search.appendNext();

      });
          
        
        xhr.onreadystatechange = null;
    }

    xhr.send(null);

    console.log("clicked");

  });

}