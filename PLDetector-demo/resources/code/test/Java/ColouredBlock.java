/*
 * ColouredBlock.java		$Date: 2004/03/28 16:28:44 $
 *
 * Paul Mucur (0346349)
 * CMPS1A4Y (Programming - Languages and Software Construction)
 *
 * A class to represent a single coloured block in the Collapsing Puzzle game.
 * Blocks can be susceptible to gravity and attraction and can be flagged for
 * removal from the game.
 */

import java.awt.*;
import javax.swing.*;
import java.awt.event.*;

public class ColouredBlock extends Block {
	
	/* Colour of this block. */
	private Color colour;
	
	/* Constructor. */
	public ColouredBlock(Color colour) {
		this.colour = colour;
	}
	
	/* Accessor method to return colour of this block. */
	public Color getColour() {
		return this.colour;
	}
	
	/* Overridden paintComponent method to display the block as a 3D square. */
	protected void paintComponent(Graphics g) {
	
		/* Set the colour of the Graphics object to the colour of the block. */
		g.setColor(this.colour);
		
		/* Fill a 3D raised rectangle with the colour. */
		g.fill3DRect(0, 0, getWidth(), getHeight(), true);
		
		/* 
		 * Cast the Graphics object into a Graphics2D object to paint the 
		 * block.
		 */
		Graphics2D g2d = (Graphics2D)g.create();
		
		/* Dispose of the Graphics2D object. */
		g2d.dispose();
	}
}
