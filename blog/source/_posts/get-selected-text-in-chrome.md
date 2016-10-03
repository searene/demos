title: get selected text in chrome
date: 2015-12-09 22:32:06
categories: Coding
tags: [chrome, javascript]
---


## EDIT

The method mentioned here is overcomplicated. To see a simple method, please refer to [my answer at stackoverflow.com](https://stackoverflow.com/questions/34170032/how-to-get-selected-text-in-chrome-extension-development/34183944#answer-34181338)

## preface

I want to get the selected text in chrome. After hours of searching and trying, I finally figured it out. It's not as simple as putting the javascript in a file and invoking the script.

## content.js

You need this file to inject your script into the target webpage. Without this file, it's impossible to get the selected text.

```javascript
chrome.runtime.sendMessage({
	'title': document.title,
	'url': window.location.href,
	'summary': window.getSelection().toString()
});
```

Notice that if you want to get the HTML source code of the selected text, you can use the following `content.js`

## content.js to get the HTML source code instead of plain text

```javascript
// http://groups.google.com/group/mozilla.dev.tech.dom/browse_thread/thread/7ecbbb066ff2027f
// Martin Honnen
//  http://JavaScript.FAQTs.com/ 
var selection = window.getSelection();
var range = selection.getRangeAt(0);
if (range) {
	var div = document.createElement('div');
	div.appendChild(range.cloneContents());
	vs=div.innerHTML;
} 
chrome.runtime.sendMessage({
	'title': document.title,
	'url': window.location.href,
	'summary': vs
});

```

Here you can see, `content.js` sent a message including the selected text. So how we get the message? To achieve this, we need something called background page, which is running in the background. It's usually called `event.js`

## event.js

```javascript
// This function is called onload in the popup code
function getPageDetails(callback) { 
	// Inject the content script into the current page 
	chrome.tabs.executeScript(null, { file: 'content.js' }); 
	// Perform the callback when a message is received from the content script
	chrome.runtime.onMessage.addListener(function(message)  { 
		// Call the callback function
		callback(message); 
	}); 
};
```


`event.js` is not always running, but it will wake up when **another view in the extension (for example, a popup) calls runtime.getBackgroundPage.**, just like the code in `popup.js`

## popup.js

```javascript
function onPageDetailsReceived(details) {
	document.getElementById('output').innerText = details.summary;
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
```

You have to declare your background page (`event.js`) and relative permissions in `manifest.json`, the sample file is as follows:

## manifest.json

```json
{
	"manifest_version": 2,
		"name": "sample",
		"description": "a sample manifest.json",
		"version": "1.0",
		"permissions": [
			"storage"
		],
		"icons": { 
			"16": "img/icon16.png",
			"48": "img/icon48.png",
			"128": "img/icon128.png" 
		},
		"background": {
			"scripts": ["event.js"],
			"persistent": false
		},
		"browser_action": {
			"default_icon": {                    
				"19": "img/icon48.png",          
				"38": "img/icon48.png"          
			},
			"default_popup": "popup.html"
		},
		"content_security_policy": "script-src 'self' https://ssl.google-analytics.com; object-src 'self'",
		"web_accessible_resources": [
			"img/icon128.png"
		],
		"permissions": [
			"tabs", 
		"http://*/*", 
		"https://*/*"
		]
}
```

Finally, this is what `popup.html` looks like

## popup.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">

<script src="popup.js"></script>
<title></title>
</head>
<body>
<div id="output"></div>
</body>
</html>
```

You can find the demo source code [here][1]

This is the whole picture:

[![the whole picture][2]][2]


---

## Reference

[Building a simple Google Chrome extension][3]

  [1]: https://github.com/searene/demos/tree/master/GetSelectedTextInChromeExtention
  [2]: http://i.stack.imgur.com/mHkC2.png
  [3]: http://markb.co.uk/building-a-simple-google-chrome-extension.html
