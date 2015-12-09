



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



chrome.extension.sendRequest({viewsource: vs}, function(response) {
  console.log(response.farewell);
});
