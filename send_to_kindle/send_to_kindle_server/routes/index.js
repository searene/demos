var express = require('express');
var fs = require('fs');
var path = require('path');
var router = express.Router();

if (!String.prototype.format) {
  String.prototype.format = function() {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function(match, number) { 
      return typeof args[number] != 'undefined'
        ? args[number]
        : match
      ;
    });
  };
}

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.post('/upload', function(req, res) {
  var plain = req.body.plain;
  var html = req.body.html;
  var plainFormat = '<html><head><link rel="stylesheet" type="text/css" href="stylesheets/style.css"></head><body><pre>{0}</pre></body></html>';
        var htmlFormat = '<link rel="stylesheet" type="text/css" href="stylesheets/style_html.css">{0}';

  // location of p.html and h.html
  var pfile = path.join(__dirname, '..', 'public', 'p.html');
  var hfile = path.join(__dirname, '..', 'public', 'h.html');

  // text that will be written into p.html/h.html
  var pContent = plainFormat.format(plain);
  var hContent = htmlFormat.format(html);

  fs.writeFile(pfile, pContent, function(err) {
    if(err) {
      return console.log(err);
    }
  });
  fs.writeFile(hfile, hContent, function(err) {
    if(err) {
      return console.log(err);
    }
  });
});

module.exports = router;
