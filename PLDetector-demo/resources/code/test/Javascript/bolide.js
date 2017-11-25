var Bolide = {
	Version: '1.0',
	Url: 'http://live.bolideapp.com/'
};

Bolide.MSIECallback = null;

/*
The server will behave differently for IE. It will not keep the connection open and IE will poll.
For all the other browser, 

*/
Bolide.Client = Class.create({
	
	// Safari need to wait before connecting or else we get a spinner
	//thx macournoyer
	CONNECT_DELAY: 0.8, //sec
	RECONNECT_DELAY: 3, //sec
	
	//statuses
	NOT_CONNECTED: 'NOT_CONNECTED',
	CONNECTED: 'CONNECTED',

	/*
	Callbacks are:
		onConnect : when the client reconnects
		onDisconnect : when the server is unreachable
		onData : when new data is available
	*/
	initialize: function(account, q, token, callbacks){
		
		this.account = account;
		this.q = q;
		this.id = 0;
		this.headEl = $$('head')[0];
		this.token = token;
		this.callbacks = callbacks;
		this.status = this.NOT_CONNECTED
		
		this.url = Bolide.Url + account + '/' + q + '/' + token;
		
		Bolide.MSIECallback = this.success.bind(this);
		
		//connect to the server
		this.connect.bind(this).delay(this.CONNECT_DELAY);
	},
	
	failure: function(transport){
		if(transport.responseText != undefined) transport = transport.responseText;
		if(this.callbacks['onFailure'] != null) this.callbacks['onFailure'](transport);
		this.connect.bind(this).delay(this.RECONNECT_DELAY);
	},
	
	success: function(transport){
		if(transport.responseText != undefined) transport = transport.responseText;
		if( this.callbacks['onSuccess'] != null ) this.callbacks['onSuccess'](transport);
		if(Prototype.Browser.IE){
			//reconnect with a delay & jsonp
			this.connect.bind(this).delay(this.RECONNECT_DELAY);
		}else{
			this.connect.bind(this).delay(this.CONNECT_DELAY);
		}
	},
	
	connect: function(){
		if(Prototype.Browser.IE){
			
			//use JSONP
			script = document.createElement('script');

			// url should have "?" parameter which is to be replaced with a global callback name
			script.src = this.url + "?jsonp=" + this.id++;

			// clean up on load: remove script tag, null script variable and delete global callback function
			script.onload = function() {
				script.remove();
				script = null;
			};
			this.headEl.appendChild(script);
			
		}else{
			new Ajax.Request(this.url, 
											{ method : 'get',
												onFailure : this.failure.bind(this),
												onSuccess : this.success.bind(this)
											}
			);	
		}
	}
})