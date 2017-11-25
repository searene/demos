/*
 * Platform.java		$Date: 2004/03/28 16:28:44 $
 *
 * Paul Mucur (0346349)
 * CMPS1A4Y (Programming - Languages and Software Construction)
 *
 * A class to represent a platform block.
 */

import java.awt.*;
import javax.swing.*;

public class Platform extends Block {
	
	/* Set as not affected by gravity. */
	private boolean subjectToGravity	= false;
	
	/* Set as not affected by attraction. */
	private boolean subjectToAttraction	= false;
	
	public boolean subjectToGravity() {
		return subjectToGravity;
	}
	
	public boolean subjectToAttraction() {
		return subjectToAttraction();
	}
	
	public void click() {
		
		/* Do nothing. */
	}
	
	/* Overridden paintComponent method to display the block as a 3D square. */
	protected void paintComponent(Graphics g) {
	
		/* Set the colour of the Graphics object to the colour of the block. */
		g.setColor(Color.lightGray);
		
		/* Fill a 3D raised rectangle with the colour. */
		g.fill3DRect(0, 0, getWidth(), getHeight(), false);
		
		/* 
		 * Cast the Graphics object into a Graphics2D object to paint the 
		 * block.
		 */
		Graphics2D g2d = (Graphics2D)g.create();
		
		/* Dispose of the Graphics2D object. */
		g2d.dispose();
	}
}