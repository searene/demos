/*
 * ColourBomb.java		$Date: 2004/03/28 16:28:44 $
 *
 * Paul Mucur (0346349)
 * CMPS1A4Y (Programming - Languages and Software Construction)
 *
 * A class to represent a ``colour bomb'' in the Collapsing Puzzle game. A 
 * colour bomb, when detonated, deletes all blocks of a certain colour from the 
 * game.
 */
 
import java.awt.*;
import javax.swing.*;
import java.awt.event.*;

public class ColourBomb extends Block {

	/* Colour of this bomb. */
	private Color colour;
	
	/* Accessor method to return the colour of this bomb. */
	public Color getColour() {
		return this.colour;
	}
	
	/* Constructor. Sets the bomb's colour. */
	public ColourBomb(Color colour) {
		this.colour = colour;
	}
	
	/* Overridden paintComponent method to display the block as an oval. */
	protected void paintComponent(Graphics g) {
	
		/* Set the colour of the Graphics object to the colour of the block. */
		g.setColor(this.colour);
		
		/* Fill an oval with the colour. */
		g.fillOval(0, 0, getWidth(), getHeight());
		
		/* 
		 * Cast the Graphics object into a Graphics2D object to paint the 
		 * block.
		 */
		Graphics2D g2d = (Graphics2D)g.create();
		
		/* Dispose of the Graphics2D object. */
		g2d.dispose();
	}
}