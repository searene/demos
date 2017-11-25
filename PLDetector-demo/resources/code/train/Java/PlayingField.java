/*
 * PlayingField.java		$Date: 2004/03/30 02:42:49 $
 *
 * Paul Mucur (0346349)
 * CMPS1A4Y (Programming - Languages and Software Construction)
 *
 * A class to visually display the game grid and control the user-interaction
 * with the game itself.
 */
 
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.io.*;
import java.util.Timer;
import java.util.TimerTask;

class PlayingField extends JPanel {
	
	/* Timer to handle the feeding row. */
	private Timer feedingtimer;
	
	/* Whether the feeding timer is running or not. */
	private boolean feedingtimerrunning = false;
	
	/* Timer to handle the time limit. */
	private Timer timelimit;
	
	/* Whether the time limit timer is running or not. */
	private boolean timelimitrunning = false;
	
	/* Grid object containing the current game. */
	private Grid	grid;
	
	/* Panel holding the playing field itself. */
	private JPanel playingfield;
	
	/* Panel holding the playing field and the feeding row. */
	private JPanel feedingrowpanel;
	
	/* Label containing the current score. */
	private JLabel score;
	
	/* Label containing the current time. */
	private JLabel timelimitlabel;
	
	/* The time limit. */
	private long	timeleft = 60000;
	
	/* Game start time. */
	private long	starttime = System.currentTimeMillis();
	
	/* Game pause time. */
	private long 	pausetime;

	/* Set up the playing field's layout, size and colour. */
	private void setUpPlayingField(int rows, int columns) {
		
		removeAll();
		
		/* Create a new border layout. */
		setLayout(new BorderLayout());
		
		/* Set the playing field itself up to be a grid. */
		playingfield = new JPanel(new GridLayout(rows, columns, 2, 2));
		
		/* The status panel. */
		JPanel status = new JPanel(new BorderLayout());
		
		/* Set the score label up. */
		score = new JLabel("Score: 0");
		
		/* Set time limit label up. */
		timelimitlabel = new JLabel("Time left: " + timeleft / 1000);
		
		/* Set up the preferred size of the playing field. */
		playingfield.setPreferredSize(new Dimension((columns * 25), 
				(rows * 25)));
		
		/* Set up the background colour of the playing field. */
		playingfield.setBackground(Color.black);
			
		if (this.grid.getGameType().equals("Feeding")) {
			
			JPanel feedinggame = new JPanel(new BorderLayout(0, 2));
		
			feedingrowpanel = new JPanel(new GridLayout(1, columns, 2, 2));
			
			feedingrowpanel.setPreferredSize(new Dimension((columns * 25), 27));
			
			feedingrowpanel.setBackground(Color.black);
			
			/* Add the playing field to the centre of the panel. */
			feedinggame.add(playingfield, BorderLayout.CENTER);
			feedinggame.add(feedingrowpanel, BorderLayout.SOUTH);
			
			add(feedinggame, BorderLayout.CENTER);
			
		} else {
			add(playingfield, BorderLayout.CENTER);
			status.add(timelimitlabel, BorderLayout.EAST);
		}
		
		status.add(score, BorderLayout.WEST);
		
		/* Add the score to the bottom of the panel. */
		add(status, BorderLayout.SOUTH);
	}
	
	/* Constructor. */
	public PlayingField(File gridFile) {
		
		/* Load grid file into Grid object. */
		this.grid = new Grid(gridFile);
		
		/* Set up playing field. */
		setUpPlayingField(this.grid.getRows(), this.grid.getColumns());
			
		/* Detect mouse clicks. */
		playingfield.addMouseListener(new PlayingFieldListener());
		
		/* Display Grid object. */
		displayGrid();
		
		/* If this is a ``Feeding'' game, start the feeding row thread. */
		if (this.grid.getGameType().equals("Feeding")) {
			startFeedingRow();
		} else {
			startTimeLimit();
		}
	}
	
	/* Load a game from a specified file. */
	public void loadGame(File gridFile) {
	
		/* Clear the panel of all objects. */
		removeAll();
		
		/* Stop the feeding row. */
		stopFeedingRow();
		
		/* Stop the time limit. */
		stopTimeLimit();
		
		/* Set the start time. */
		starttime = System.currentTimeMillis();
		
		/* Load grid file into Grid object. */
		this.grid = new Grid(gridFile);
		
		/* Set up playing field. */
		setUpPlayingField(this.grid.getRows(), this.grid.getColumns());
			
		/* Detect mouse clicks. */
		playingfield.addMouseListener(new PlayingFieldListener());
		
		/* Display Grid object. */
		displayGrid();
		
		/* Update the display. */
		updateDisplay();
		
		/* If this is a ``Feeding'' game, start the feeding row thread. */
		if (this.grid.getGameType().equals("Feeding")) {
			startFeedingRow();
		} else {
			startTimeLimit();
		}
	}
	
	/* Create a new game of a specified type and difficulty. */
	public void newGame(String gameType, int difficulty) {
	
		/* Clear the panel of all objects. */
		removeAll();
		
		/* Stop the feeding row. */
		stopFeedingRow();
		
		/* Stop the time limit. */
		stopTimeLimit();
		
		/* Set the start time. */
		starttime = System.currentTimeMillis();
		
		/* Load grid file into Grid object. */
		this.grid = new Grid(gameType, difficulty);
		
		/* Set up playing field. */
		setUpPlayingField(this.grid.getRows(), this.grid.getColumns());
			
		/* Detect mouse clicks. */
		playingfield.addMouseListener(new PlayingFieldListener());
		
		/* Display Grid object. */
		displayGrid();
		
		/* Update the display. */
		updateDisplay();
		
		/* If this is a ``Feeding'' game, start the feeding row thread. */
		if (this.grid.getGameType().equals("Feeding")) {
			startFeedingRow();
		} else {
			startTimeLimit();
		}
	}
	
	/* Saves the game to a specified file. */
	public void saveGame(File gridFile) {
		this.grid.saveGame(gridFile);
	}
	
	/* Constructor. */
	public PlayingField(String gameType, int difficulty) {
		
		/* Load grid file into Grid object. */
		this.grid = new Grid(gameType, difficulty);
		
		/* Set up playing field. */
		setUpPlayingField(this.grid.getRows(), this.grid.getColumns());
				
		/* Detect mouse clicks. */
		playingfield.addMouseListener(new PlayingFieldListener());
		
		/* Display Grid object. */
		displayGrid();
		
		/* If this is a ``Feeding'' game, start the feeding row thread. */
		if (this.grid.getGameType().equals("Feeding")) {
			startFeedingRow();
		} else {
			startTimeLimit();
		}
	}
	
	/* If it isn't already running, this starts the feeding row. */
	public void startFeedingRow() {
		if (!feedingtimerrunning) {
			feedingtimerrunning = true;
			feedingtimer = new Timer();
			feedingtimer.schedule(new FeedRow(), 0, 
					2000/this.grid.getDifficulty());
		}
	}
	
	/* If it is already running, this stops the feeding row. */
	public void stopFeedingRow() {
		if (feedingtimerrunning) {
			feedingtimerrunning = false;
			feedingtimer.cancel();
		}
	}
	
	/* If it isn't already running, this starts the time limit. */
	public void startTimeLimit() {
		if (!timelimitrunning) {
			timelimitrunning = true;
			timelimit = new Timer();
			timelimit.schedule(new Countdown(), 0, 1000);
		}
	}
	
	/* If it is already running this stops the time limit. */
	public void stopTimeLimit() {
		if (timelimitrunning) {
			timelimitrunning = false;
			timelimit.cancel();
		}
	}
	
	/* Pause time limit. */
	public void pauseTimeLimit() {
		pausetime = System.currentTimeMillis();
	}
	
	/* Resume time limit. */
	public void resumeTimeLimit() {
		starttime = starttime + (System.currentTimeMillis() - pausetime);
	}
	
	/* What to do when a mouse click is detected. */
	private class PlayingFieldListener implements MouseListener {
		public void mousePressed(MouseEvent event) {
			int column;
			int row;
			
			if (grid.getGameState() == grid.PLAYING) {
				
				/* 
				 * Detect which column the block that has been clicked on is 
				 * in. 
				 */
				column = event.getX() / (grid.getBlock(0, 0).getWidth() + 2);
				
				/* Detect which row the block that has been clicked on is in. */
				row = event.getY() / (grid.getBlock(0, 0).getHeight() + 2);
				
				/* Click on the block. */
				grid.getBlock(row, column).click();
				
				/* Update the display accordingly. */
				updateDisplay();
			}
		}
		
		public void mouseClicked(MouseEvent event) {}
		public void mouseReleased(MouseEvent event) {}
		public void mouseEntered(MouseEvent event) {}
		public void mouseExited(MouseEvent event) {}
	}
	
	/* Returns true if the game is over, false if still going on. */
	public boolean isGameOver() {
		if (this.grid.getGameState() == grid.PLAYING) {
			return false;
		} else {
			return true;
		}
	}
	
	/* Update the playing field. */
	private void updateDisplay() {
	
		/* Update the grid (detect block removal, gravity, attraction etc.). */
		this.grid.updateGrid();
		
		/* Check if the game is over. */
		if (this.grid.getGameState() != grid.PLAYING) {
			displayGameOverMessage(this.grid.getGameState());
		} else {
			
			if (grid.getGameType().equals("Feeding")) {
				displayFeedingRow();
			}
			displayGrid();
		}
		
		/* Update the score display. */
		score.setText("Score: " + new Integer(this.grid.getScore()).toString());
		
		/* Repaint the whole playing field. */
		updateUI();
	}
	
	private void updateTimeLeft() {
	
		/* Update the time limit. */
		timelimitlabel.setText("Time left: " + (timeleft 
				- ((System.currentTimeMillis() - starttime))) / 1000);
	}
	
	/* Ends the current game and displays a message. */
	private void displayGameOverMessage(int endCode) {
		
		/* Stop the feeding row thread. */
		stopFeedingRow();
		
		/* Stop the time limit. */
		stopTimeLimit();
		
		/* Calculate time-related bonus points. */
		long timeBonus = (timeleft - ((System.currentTimeMillis() - starttime))) 
				/ 100;
				
		/* Labels for displaying the end of game message. */
		JLabel messageDisplay;
		JLabel titleDisplay;
		
		/* Strings to contain the different end of game messages. */
		String title 	= new String();
		String message	= new String();
		
		/* Clear the panel of all components. */
		playingfield.removeAll();
		
		/* Set the display as a flow layout. */
		playingfield.setLayout(new FlowLayout());
		
		/* Set the messages to display determined by the end game code. */
		switch (endCode) {
			
			/* When the game is successfully won. */
			case Grid.WON:
				title = "You won!";
				if (grid.getGameType().equals("Basic")) {
					message = "Your final score (with time bonus) was " 
							+ (grid.getScore() + timeBonus) + ".";
				} else {
					message = "Your final score was " + grid.getScore() + ".";
				}
				break;
			
			/* When the game is lost. */
			case Grid.LOST:
				title = "You lost!";
				message = "Your final score was " + grid.getScore() + ".";
				break;
		}
		
		titleDisplay = new JLabel(title, JLabel.CENTER);
		titleDisplay.setVerticalAlignment(JLabel.BOTTOM);
		titleDisplay.setForeground(Color.white);
		titleDisplay.setPreferredSize(new Dimension(getWidth(), 
				(getHeight()/2)));
		titleDisplay.setFont(new Font("SansSerif", Font.BOLD, 24));
		
		messageDisplay = new JLabel(message, JLabel.CENTER);
		messageDisplay.setForeground(Color.white);
		messageDisplay.setFont(new Font("SansSerif", Font.BOLD, 12));
		
		playingfield.add(titleDisplay);
		playingfield.add(messageDisplay);
	}
	
	private void displayGrid() {	
		
		/* Clear the panel of all components. */
		playingfield.removeAll();
		
		/* Traverse each row in the grid. */
		for (int row = 0; row < this.grid.getRows(); row++) {
			
			/* Traverse each column in the row. */
			for (int column = 0; column < this.grid.getColumns(); column++) {
				
				/* Add the block from the grid to the panel. */
				this.playingfield.add(grid.getBlock(row, column));
			}
		}	
	}
	
	private void displayFeedingRow() {
	
		/* Clear the panel of all components. */
		feedingrowpanel.removeAll();
			
		/* Traverse each column in the row. */
		for (int column = 0; column < this.grid.getColumns(); column++) {
			
			/* 
			 * Add the block from the feeding row to the feeding row 
			 * panel. 
			 */
			this.feedingrowpanel.add(grid.getFeedingRowBlock(column));
		}
	}
	
	/* Control the feeding row. */
	class FeedRow extends TimerTask {	
		public void run() {
			if (grid.getGameType().equals("Feeding")) {
				if (grid.addToFeedingRow()) {
				
					/* 
					 * If a new row has been added to the playing field,
					 * update it.
					 */
					updateDisplay();
				}
				
				/* Display the feeding row and update it. */
				displayFeedingRow();
				feedingrowpanel.updateUI();
			}
		}
	}
	
	/* Control the time limit. */
	class Countdown extends TimerTask {
		public void run() {
			if ((timeleft - ((System.currentTimeMillis() - starttime))) < 1) { 
				grid.setGameState(Grid.LOST);
				updateDisplay();
			} else {
				updateTimeLeft();
				timelimitlabel.repaint();
			}
		}
	}
	
	public static void main (String[] args) {
		JFrame frame = new JFrame("My Collapsing Puzzle");
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		PlayingField test = new PlayingField("Feeding", 5);
		frame.getContentPane().add(test);
		
		frame.pack();
		frame.show();
	}
	
}