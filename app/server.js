'use strict';

const express = require('express'),
      http = require('http'),
      redis = require('redis'),
      os = require('os');

const client = redis.createClient(6379, 'redis');
const app = express();

app.get('/', function(req, res, next) {
  client.incr('visits', function(err, visits) {
    if(err) return next(err);    
    res.set('Content-Type', 'text/html');
    res.send('Hello CloudCover, you have ' + visits + ' visitors on this page');
  });
});

const appPort = 8080;
http.createServer(app).listen(appPort, function() {
  console.log('Listening on port ' + appPort);
});
