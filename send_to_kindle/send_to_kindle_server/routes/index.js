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

  // location of p.html
  var pfile = path.join(__dirname, '..', 'public', 'p.html');
  console.log(pfile);

  // text that will be written into p.html
  var pContent = plainFormat.format(plain);

  fs.writeFile(pfile, pContent, function(err) {
    if(err) {
      return console.log(err);
    }
  });
});

module.exports = router;
