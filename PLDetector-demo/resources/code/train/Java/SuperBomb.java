/*
 * SuperBomb.java		$Date: 2004/03/28 16:28:44 $
 *
 * Paul Mucur (0346349)
 * CMPS1A4Y (Programming - Languages and Software Construction)
 *
 * A class to represent a super bomb which, when detonated, destroys all blocks 
 * regardless of type within its range.
 */

import java.awt.event.*;
import java.awt.*;
import javax.swing.*;

public class SuperBomb extends Block {
	
	/* Range of the super bomb. */
	private int range = 4;
	
	/* Accessor method to return the range of the super bomb. */
	public int getRange() {
		return range;
	}
	
	/* Overridden paintComponent method to display the block as an oval. */
	protected void paintComponent(Graphics g) {
	
		/* Set the colour of the Graphics object to the colour of the block. */
		g.setColor(Color.red);
		g.fillOval(0, 0, getWidth(), getHeight());
		g.setColor(Color.black);
		g.fillOval(2, 2, getWidth()-4, getHeight()-4);
		
		Graphics2D g2d = (Graphics2D)g.create();
		g2d.dispose();
	}
}