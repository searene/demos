// var HOST = 'http://searene.party';
var HOST = 'http://searene.party';
var PORT = '3000';

function upload(plain, html) {
  $.ajax({
    method: 'POST',
    url: HOST + ':' + PORT + '/upload',
    data: {plain: plain, html: html}
  });
}

function onPageDetailsReceived(details) {
  // get html
  var htmlCode = details.summary;
  var sel = window.getSelection && window.getSelection();
    if (sel && sel.rangeCount > 0) {
      var range = sel.getRangeAt(0);
      if (range) {
          var div = document.createElement('div');
          div.appendChild(range.cloneContents());
          htmlCode = div.innerHTML;
      }
  }
  $("#html").html(htmlCode);

  chrome.tabs.executeScript( {
    code: "window.getSelection().toString();"
  }, function(selection) {

    // get plain text
    var plainText = selection[0];

    // display plain and html in popup.html
    $("#plain").html(plainText);
  });

  // upload plain and html texts to server
  upload(plainText, htmlCode);
}

// When the popup HTML has loaded
window.addEventListener('load', function(evt) {
  // Get the event page
  chrome.runtime.getBackgroundPage(function(eventPage) {
      // Call the getPageInfo function in the event page, passing in 
      // our onPageDetailsReceived function as the callback. This injects 
      // content.js into the current tab's HTML
      eventPage.getPageDetails(onPageDetailsReceived);
    });
});
