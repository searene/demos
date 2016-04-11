function navbar() {
	//---------------------------------------------
	// navbar animation when scrolling
	//---------------------------------------------
	var previousScroll = 0;
	var currentScroll = 0;
	$(window).scroll(function() {
		currentScroll = $(this).scrollTop();
		var speed = 300;
		if (currentScroll > previousScroll) {
			$('#header').hide(speed);
		} else {
			$('#header').show(speed);
		}
		previousScroll = currentScroll;
	});
}

function rightColumn() {
	//---------------------------------------------
	// keep the right column in view when scrolling
	//---------------------------------------------
	var currentScroll = 0;
	var previousScroll = 0;
	var elem = $('.layout-right-column');

	// get the height of the right column
	var elInJS = document.getElementsByClassName('layout-right-column')[0];
	var elHeight = elInJS.offsetHeight;
	elHeight += parseInt(window.getComputedStyle(elInJS).getPropertyValue('margin-top'));
	elHeight += parseInt(window.getComputedStyle(elInJS).getPropertyValue('margin-bottom'));

	// record the original top and bottom value of elem
	elem.css('position', 'inherit');
	while(true) {
		// the while loop is used to make sure the position is not fixed before fetching the position of elem
		if(elem.css('position') != 'fixed') {
			break
		}
	}
	elTop = elem.offset().top;
	elBottom = elTop + elHeight;

	$(window).scroll(function() {
		currentScroll = $(this).scrollTop();

		// scrolling down
		if(currentScroll > previousScroll) {

			// hit the bottom
			if(currentScroll + $(window).height() > elBottom) {
				elem.css('position','fixed');
				elem.css('top', 'auto');
				elem.css('bottom', '0');
				elem.css('right', '0');

			// haven't hit the bottom
			} else {
				
				elem.css('position', 'inherit');
			}

		// scrolling up
		} else {
			
			// haven't hit the top
			if(currentScroll > elTop) {

				if(elem.css('position') === 'fixed') {

					// the top of elem is in view, fix the position
					if(elInJS.getBoundingClientRect().top >= 0) {

						elem.css('top', '0');
						elem.css('bottom', 'auto');
						elem.css('right', '0');
					} else {
						// the top of elem is not in view, we can keep scrolling it
						scrollOffset = previousScroll - currentScroll;
						bottomToBe = parseInt(elem.css('bottom')) - scrollOffset;
						elem.css('top', 'auto');
						elem.css('bottom', bottomToBe);
						elem.css('right', '0');
					}
				}
			} else {
				// hit the top
				elem.css('position', 'inherit');
			}
		}
		previousScroll = currentScroll;
	});
}

$(document).ready(function() {
	navbar();
	rightColumn()
})
