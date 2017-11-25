/*
 * IndestructibleBlock.java		$Date: 2004/03/28 16:28:44 $
 *
 * Paul Mucur (0346349)
 * CMPS1A4Y (Programming - Languages and Software Construction)
 *
 * A class to represent an indestructible block.
 */

import java.awt.*;
import javax.swing.*;

public class IndestructibleBlock extends Block {
	
	/* Overridden paintComponent method to display the block as a 3D square. */
	protected void paintComponent(Graphics g) {
	
		/* Set the colour of the Graphics object to the colour of the block. */
		g.setColor(Color.lightGray);
		
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
	
	public void click() {
		
		/* Do nothing. */
	}
}