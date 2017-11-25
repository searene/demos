import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.io.*;

public class Game extends JPanel implements ActionListener {
	
	/* The current game being played. */
	private PlayingField currentgame;
	
	/* Constructor. Starts an easy feeding game by default. */
	public Game() {
		this.currentgame = new PlayingField("Feeding", 3);
	}
	
	/* Creates the content pane for the frame. */
	public Container createContentPane() {
		JPanel contentPane = new JPanel();
		contentPane.add(this.currentgame);
		return contentPane;
	}
	
	/* Creates the game menu. */
	public JMenuBar createMenuBar() {
		JMenuBar menuBar = new JMenuBar();
		
		/* Create top-level ``Game'' menu. */
		JMenu gameMenu = new JMenu("Game");
		
		/* Create ``New'' sub-menu. */
		JMenu newGame = new JMenu("New");
		
		/* Create items for ``New'' sub-menu. */
		JMenuItem basicGame = new JMenuItem("Basic game");
		JMenuItem easyFeedingGame = new JMenuItem("Easy feeding game");
		JMenuItem moderateFeedingGame = new JMenuItem("Moderate feeding game");
		JMenuItem hardFeedingGame = new JMenuItem("Hard feeding game");
		
		/* Create items for main ``Game'' menu. */
		JMenuItem save = new JMenuItem("Save...");
		JMenuItem load = new JMenuItem("Load...");
		JMenuItem quit = new JMenuItem("Quit");
		
		/* Add the ``Game'' menu to the menu bar. */
		menuBar.add(gameMenu);
		
		/* Add the ``New'' sub-menu to the ``Game'' menu. */
		gameMenu.add(newGame);
		
		/* 
		 * Add the basic game option to the ``New'' menu and set up the action
		 * listener.
		 */
		newGame.add(basicGame);
		basicGame.addActionListener(this);
		
		/* 
		 * Add the easy feeding game option to the ``New'' menu and set up the 
		 * action listener.
		 */
		newGame.add(easyFeedingGame);
		easyFeedingGame.addActionListener(this);
		
		/* 
		 * Add the moderate feeding game option to the ``New'' menu and set up 
		 * the action listener.
		 */
		newGame.add(moderateFeedingGame);
		moderateFeedingGame.addActionListener(this);
		
		/* 
		 * Add the hard feeding game option to the ``New'' menu and set up the 
		 * action listener.
		 */
		newGame.add(hardFeedingGame);
		hardFeedingGame.addActionListener(this);
		
		/* 
		 * Add the save option to the ``Game'' menu and set up the  action 
		 * listener.
		 */
		gameMenu.add(save);
		save.addActionListener(this);
		
		/* 
		 * Add the load option to the ``Game'' menu and set up the  action 
		 * listener.
		 */
		gameMenu.add(load);
		load.addActionListener(this);
		
		/* 
		 * Add the quit option to the ``Game'' menu and set up the  action 
		 * listener.
		 */
		gameMenu.add(quit);
		quit.addActionListener(this);
		
		return menuBar;
	}
	
	/*
	 * Controls what happens when an action is detected (a menu item is
	 * selected).
	 */
	public void actionPerformed(ActionEvent e) {
	
		/* The file to load from or save to. */
		File file;
		
		/* Cast the source of the ActionEvent into a menu item for selection. */
		JMenuItem source = (JMenuItem)(e.getSource());
		
		/* Detect which menu item was clicked. */
		if (source.getText().equals("Basic game")) {
		
			/* Upon selecting a new basic game, create a new basic game. */
			this.currentgame.newGame("Basic", 5);
			
		} else if (source.getText().equals("Easy feeding game")) {
			
			/* 
			 * Upon selecting an easy feeding game, create a new easy feeding
			 * game.
			 */
			this.currentgame.newGame("Feeding", 3);
			
		} else if (source.getText().equals("Moderate feeding game")) {
		
			/* 
			 * Upon selecting a moderate feeding game, create a new moderate 
			 * feeding game.
			 */
			this.currentgame.newGame("Feeding", 4);
			
		} else if (source.getText().equals("Hard feeding game")) {
			
			/* 
			 * Upon selecting a hard feeding game, create a new hard feeding
			 * game.
			 */
			currentgame.newGame("Feeding", 10);
		
		} else if (source.getText().equals("Load...")) {
			
			/* Pause the game. */
			this.currentgame.stopFeedingRow();
			this.currentgame.pauseTimeLimit();
			this.currentgame.stopTimeLimit();
				
			/* 
			 * Present the user with a file chooser dialog to select the file
			 * to load.
			 */
			file = getInputFile("Choose game to load");
			
			if (file != null) {
			
				/* If the user chose a file, load it. */
				this.currentgame.loadGame(file);
				
			} else {
				
				/* If a user cancelled loading resume play. */
				this.currentgame.startFeedingRow();
				this.currentgame.resumeTimeLimit();
				this.currentgame.startTimeLimit();
			}
			
		} else if (source.getText().equals("Save...")) {
		
			/* If the game is still going on... */
			if (!this.currentgame.isGameOver()) {
				
				/* Pause the game. */
				this.currentgame.stopFeedingRow();
				this.currentgame.stopTimeLimit();
				this.currentgame.pauseTimeLimit();
				
				/* 
				 * Present the user with a file chooser dialog to choose where
				 * they want to save to.
				 */
				file = getOutputFile("Choose where to save");
				
				if (file != null) {
				
					/* If a file is selected, save to it. */
					this.currentgame.saveGame(file);
					
				}
				
				/* Resume play. */
				this.currentgame.startFeedingRow();
				this.currentgame.resumeTimeLimit();
				this.currentgame.startTimeLimit();
				
			} else {
			
				/* 
				 * Emit a system beep to alert the user that the game cannot
				 * be saved at this time.
				 */
				Toolkit.getDefaultToolkit().beep();
			}
			
		} else if (source.getText().equals("Quit")) {
		
			/* Quit the game. */
			System.exit(0);
		}
	}
	
	/* 
	 * Present the user with a file chooser dialog to select a file for input. 
	 * The title of the dialog box is determined by the ``caption'' argument.
	 */
	public File getInputFile(String caption) {
	
		JFileChooser chooser = new JFileChooser();
		chooser.setDialogTitle(caption);
		int openReturnVal = chooser.showOpenDialog(null);
		if (openReturnVal == JFileChooser.APPROVE_OPTION) {
			return chooser.getSelectedFile();
		} else {
			return null;
		}
	}
	
	/* 
	 * Present the user with a file chooser dialog to select a file for 
	 * output. The title of the dialog box is determined by the ``caption''
	 * argument.
	 */
	public File getOutputFile(String caption) {
	
		JFileChooser outputdialog = new JFileChooser();
		outputdialog.setDialogTitle(caption);
		int openReturnVal = outputdialog.showSaveDialog(null);
		if (openReturnVal == JFileChooser.APPROVE_OPTION) {
			return outputdialog.getSelectedFile();
		} else {
			return null;
		}
	}
	
	/* 
	 * Return the size of the game plus some space to take the menu bar into
	 * account.
	 */
	public Dimension getGameSize() {
		Dimension d = this.currentgame.getPreferredSize();
		d.setSize(d.getWidth(), d.getHeight() + 55);
		return d;
	}
	
	/* Create and show the graphical user interface. */
	private static void createAndShowGUI() {
		JFrame frame = new JFrame("My Collapsing Puzzle");
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		Game game = new Game();
		frame.setJMenuBar(game.createMenuBar());
		frame.setContentPane(game.createContentPane());
		frame.setSize(game.getGameSize());
		
		frame.setVisible(true);
	}
	
	/* Run the game. */
	public static void main(String[] args) {
		javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                createAndShowGUI();
            }
        });
	}
}