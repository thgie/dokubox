var fs = require('fs'); 

var config = JSON.parse(fs.readFileSync('data/config.json', 'utf8'));

var Flickr = require("flickrapi");
flickrOptions = {
  key: config.flickr.consumer_key,
  secret: config.flickr.consumer_secret,
  access_token: config.flickr.access_token,
  access_token_secret: config.flickr.access_token_secret,
  permissions: "delete"
};

Flickr.authenticate(flickrOptions, function(error, flickr) {

});