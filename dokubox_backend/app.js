var express = require('express');
var server = express();
var fs = require('fs');
var i = 0;

var flickr = require('flickr-with-uploads');
var twitter_update_with_media = require('twitter_update_with_media');

var config = JSON.parse(fs.readFileSync('data/config.json', 'utf8'));

var flickr_bot = flickr(
  config.flickr.consumer_key,
  config.flickr.consumer_secret,
  config.flickr.access_token,
  config.flickr.access_token_secret
);

var twitter_bot = new twitter_update_with_media({
    consumer_key:         config.twitter.consumer_key
  , consumer_secret:      config.twitter.consumer_secret
  , token:         config.twitter.access_token
  , token_secret:  config.twitter.access_token_secret
});

server.configure(function(){
  server.use('/assets', express.static(__dirname + '/assets'));
  server.use(express.static(__dirname + '/public'));
});

server.get('/', function(req, res){
 	
});

server.post('/upload', function(req, res){

	i++;
	var full_path = __dirname + '/data/projects/snapshot'+i+'.jpg';
	var fsws = fs.createWriteStream(full_path);

	req.pipe(fsws);
	fsws.on('finish', function(){
		flickr_bot({
		  title: 'Another project from FabLab Luzern',
		  method: 'upload',
		  is_public: 1,
		  hidden: 2,
		  photo: fs.createReadStream(full_path)
		}, function(err, response) {
		  if (err) {
		    console.error('Could not upload photo:', err);
		  }
		  else {
		    
		  }
		});
		twitter_bot.post('Another project from FabLab Luzern.', full_path, function(err, response) {
			if (err) {
				console.log(err);
			}
		});
	});
});

server.listen(3000);
console.log('Listening on port 3000');