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
  chrome.tabs.executeScript( {
    code: "window.getSelection().toString();"
  }, function(selection) {

    // get plain text
    var plainText = selection[0];

    // upload plain and html texts to server
    upload(plainText, htmlCode);
  });
}

function getPageDetails(callback) { 
	// Inject the content script into the current page 
	chrome.tabs.executeScript(null, { file: 'content.js' }); 
	// Perform the callback when a message is received from the content script
	chrome.runtime.onMessage.addListener(function(message)  { 
		// Call the callback function
		callback(message); 
	}); 
};

chrome.browserAction.onClicked.addListener(function(tab) {
  getPageDetails(onPageDetailsReceived);
});

