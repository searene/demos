/*
 * Block.java		$Date: 2004/03/28 16:28:44 $
 *
 * Paul Mucur (0346349)
 * CMPS1A4Y (Programming - Languages and Software Construction)
 *
 * An abstract class to represent a single block in the Collapsing Puzzle game.
 * Blocks can be susceptible to gravity and attraction and can be flagged for
 * removal from the game.
 */
 
import javax.swing.*;

abstract class Block extends JComponent {

	/* Determines whether this block is affected by gravity or not. */
	boolean subjectToGravity	= true;
	
	/* Determines whether this block is affected by attraction or not. */
	boolean subjectToAttraction	= true;
	
	/* Determines whether this block needs to be removed or not. */
	boolean toBeRemoved			= false;
	
	/* 
	 * Accessor method to return whether or not a block is subject to 
	 * gravity.
	 */
	public boolean subjectToGravity() {
		return subjectToGravity;
	}
	
	/*
	 * Accessor method to return whether or not a block is subject to 
	 * attraction.
	 */
	public boolean subjectToAttraction() {
		return subjectToAttraction;
	}
	
	/* Accessor method to return whether or not a block is to be removed. */
	public boolean toBeRemoved() {
		return toBeRemoved;
	}
	
	/* When the block is clicked on, flag it for removal. */
	public void click() {
		this.toBeRemoved = true;
	}
	
	/* Resets a block so that it is no longer set to be removed. */
	public void reset() {
		this.toBeRemoved = false;
	}
}