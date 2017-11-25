// prototypeGrowl - Growl for Prototype
//
// Craig P Jolicoeur <cpjolicoeur@gmail.com - http://github.com/cpjolicoeur>
// Thomas Reynolds <tdreyno@gmail.com - http://github.com/tdreyno>
//
// Version: 1.0
// 
// Copyright (c) 2008 Thomas Reynolds, Craig P Jolicoeur
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
// --------------------------------------------------------------------------

var Growl = {};
Growl.Base = Class.create({
	options: {
		image:   'growl.jpg',
		title:   'Default popup title',
		text:    'Lorem ipsum, whatever',
		autohide: 2,
		animated: 0.75,
    animation: { show: Effect.Appear, hide: Effect.Fade },
		opacity: 1
	},
	
	create: function(class_names) {
		var elem = new Element('div', { 'class': class_names }).hide();
		elem.insert({ bottom: new Element('img') });
		elem.insert({ bottom: new Element('h3') });
		elem.insert({ bottom: new Element('p') });
		$(document.body).insert({ bottom: elem });
		elem.setOpacity(this.options.opacity);
		
		return elem;
	},
	
	show: function(elem, options) {
		if ( this.options.animated && this.options.animation.show )
      new this.options.animation.show( elem, { duration: this.options.animated } );
		else
			elem.show();
		
		if (this.options.autohide)
			this.hide.bind(this, elem).delay(options.autohide);
		else {
			elem.observe('click', function(event) {
				this.hide(event.findElement('div'));
			}.bindAsEventListener(this));
		}
	},
	
	hide: function(elem) {
		if ( this.options.animated && this.options.animation.hide ) {
			new this.options.animation.hide( elem, { 
				duration:            this.options.animated, 
				afterFinishInternal: elem.remove.bind(elem)
			} )
		} else
			elem.remove();
	}
});

Growl.Smoke = Class.create(Growl.Base, {
	cache:    $H({}),
	from_top: 0,
	
	show: function($super) {
		var options  = Object.extend(this.options, arguments[1] || {});
		var elem = this.create(options.class_names || 'growl-smoke');
		
		var delta = document.viewport.getScrollOffsets()[1] + this.from_top;
		elem.setStyle({ top: delta+'px' });
		
		elem.down('img').setAttribute('src', options.image);
		elem.down('h3').update(options.title);
		elem.down('p').update(options.text);
		
		this.from_top += elem.getHeight();
		this.cache.set(elem.identify(), true);
		
		$super(elem, options);
	},
	
	hide: function($super, elem) {
		$super(elem);
		this.cache.unset(elem.identify());
		
		if (this.cache.keys().length == 0)
			this.from_top = 0;
	}
});

Growl.Bezel = Class.create(Growl.Base, {
	cache:    $H({}),
	queue:    $A({}),
	from_top: 0,

	show: function($super) {
		if (this.cache.keys().length == 0) {
			this.options.animation.hide = Effect.DropOut;
	
			var options  = Object.extend(this.options, arguments[1] || {});
			var elem = this.create(options.class_names || 'growl-bezel');
		
			var offsets = document.viewport.getDimensions();
			var top = (offsets['height']/2)-105;
			var left = (offsets['width']/2)-103;
			elem.setStyle({ top: top+'px', left: left+'px' });
		
			elem.down('img').setAttribute('src', options.image);
			elem.down('h3').update(options.title);
			elem.down('p').update(options.text);
		
			this.cache.set(elem.identify(), true);
		
			$super(elem, options);			
		} else {
			this.queue.push(arguments[1] || {});
		}
	},
	
	hide: function($super, elem) {
		$super(elem);
		this.cache.unset(elem.identify());
		
		if (this.queue.length > 0) {
			var options = this.queue.first();
			this.queue = this.queue.without(options);
			this.show.bind(this, options).delay(0.5);
		}
			
	}
});
