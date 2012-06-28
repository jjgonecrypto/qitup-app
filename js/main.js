var sp = getSpotifyApi(1);

exports.init = init;

function init() {
  var models = sp.require('sp://import/scripts/api/models');
 
  var hashtag = document.getElementById('hashtag');
  var searchBtn = document.getElementById('search');
  var status = document.getElementById('details');

  searchBtn.addEventListener('click', function() {
    status.innerHTML = "";

    var playlist = new models.Playlist();
    var xhr = new XMLHttpRequest();
    var request = 'http://search.twitter.com/search.json?q=' + hashtag.value;

    xhr.open('GET', request);

    xhr.onreadystatechange = function () {
      if (xhr.readyState != 4) return;

      var data = JSON.parse(xhr.responseText);
      var html = "";
      data.results.forEach(function(result) {
        var tweet = result.text;

        var trackName = tweet.match(/(?=play:).+?(?=\s)/i)[0].substr(5);
        if (trackName.length) {
          var search = new models.Search(trackName);

          search.observe(models.EVENT.CHANGE, function() {

            if (search.tracks.length) {
              var track = search.tracks[0];

              if (playlist.indexOf(track) >= 0) return;
              playlist.add(track);
              if (playlist.length == 1) models.player.play(track, playlist, 0);

              html += "<li><ul class='inline'>";
              html += "<li>" + image(track.image) + "</li>";
              html += "<li class='track'><strong>" + track.name + "</strong><br />by " + track.artists[0].name + "</li>"; 
              html += "<li>" + image(result.profile_image_url) + "</li>";
              html += "<li class='user'><a href='http://twitter.com/"+result.from_user+"'>" + result.from_user_name + " (@"+result.from_user+")" + "</a></li>";
              html += "</ul></li>";
            }

            status.innerHTML = "<ul class='results'>" + html + "</ul>";
            search.ignore(models.EVENT.CHANGE);     
          });

          search.appendNext();
        }

      });
        
      xhr.onreadystatechange = null;
    }

    xhr.send(null);

  });

}

//helper to output html of an <img> tag
function image(uri, width, height) {
  var img;
  width = width || 50;
  height = height || 50;
  img = new Image(width, height);
  img.src = uri;
  return img.outerHTML;
}