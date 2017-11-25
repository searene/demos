/*
 * Grid.java		$Date: 2004/03/30 02:42:49 $
 *
 * Paul Mucur (0346349)
 * CMPS1A4Y (Programming - Languages and Software Construction)
 *
 * A class to represent the game grid using a two-dimensional array of Block
 * objects. This class controls where blocks are, which blocks exist etc. It
 * applies gravity and attraction to the game and also manages what happens
 * when a block is clicked on: it removes clusters, detonates bombs etc. It
 * also feeds new rows to the game and keeps track of the score.
 */

import java.io.*;
import java.util.*;
import java.awt.*;

public class Grid {
			
	/* Constants for game state codes. */
	public final static int PLAYING = 2;
	public final static int LOST 	= 1;
	public final static int WON 	= 0;
	
	/* Game state code. */
	private int gameState = PLAYING;
	
	/* The playing field as a two-dimensional array of Blocks. */
	private Block[][]	grid;
	
	/* The feeding row. */
	private Block[]		feedingRow;
	
	/*
	 * The playing field as a two-dimensional array of boolean values, used for
	 * defining clusters of blocks: when a block is checked, its position is
	 * set as ``true'' in the checking grid.
	 */
	private boolean[][]	checkingGrid;
	private boolean[][]	detectionCheckingGrid;
	
	/* The current score in the game. */
	private int			score;
	
	/* Number of blocks currently detected in a cluster. */
	private int			numberInCluster;
	private int			detectionNumberInCluster;
	
	/* Type of game. */
	private String		gameType;
	
	/* Difficulty level of the game. */
	private int			difficulty	= 3;
	
	/* Random number generator, used for creating random rows of blocks. */
	private Random generator = new Random();
	
	/* Accessor method to return the type of game. */
	public String getGameType() {
		return gameType;
	}
	
	/* Accessor method to return the number of rows in the grid. */
	public int getRows() {
		return grid.length;
	}
	
	/* Accessor method to return the current score. */
	public int getScore() {
		return score;
	}
	
	/* Accessor method to return the number of columns in the grid. */
	public int getColumns() {
		return grid[0].length;
	}
	
	/* Accessor method to return a single block from the grid. */
	public Block getBlock(int row, int column) {
		return grid[row][column];
	}
	
	public Block getFeedingRowBlock(int column) {
		return feedingRow[column];
	}
	
	/* Accessor method to return the difficulty level of the game. */
	public int getDifficulty() {
		return difficulty;
	}
	
	/* Accessor method to set the difficulty level of the game. */
	public void setDifficulty(int difficulty) {
		this.difficulty = difficulty;
	}

	/* Returns the game state code. */
	public int getGameState() {
		return this.gameState;
	}
	
	/* Returns the type of game. */
	public void setGameType(String gameType) {
		this.gameType = gameType;
	}
	
	/* Set the game state code. */
	public void setGameState(int gameState) {
		this.gameState = gameState;
	}
	
	/* Set the game score. */
	public void setScore(int score) {
		this.score = score;
	}
	
	/* 
	 * Constructor. Reads in grid file and turns it into two-dimensional Block
	 * array.
	 */
	public Grid(File gridFile) {
		try {
		
			/* BufferedReader to read in one line of the grid file at a time. */
			BufferedReader	reader	
					= new BufferedReader(new FileReader(gridFile));
			
			/* StringTokenizer to tokenize each line at a time. */
			StringTokenizer tokenizer;
			
			/* String containing current line being read. */
			String			line 		= reader.readLine();
			
			/* String containing current token being read. */
			String 			token 		= new String();
			
			/* Flag to indicate that a line is a comment. */
			boolean 		comment		= false;
			
			/* Current row of the grid. */
			int 			row 		= -1;
			
			/* Current column of the grid. */
			int 			column 		= 0;
			
			/* Number of rows in the grid file as indicated by "Rows: ". */
			int 			rows 		= 0;
			
			/* Number of columns in the grid file. */
			int 			columns 	= 0;
			
			/* Flag to indicate whether the grid is being read in or not. */
			boolean 		readGrid 	= false;
			
			/* Flag to indicate whether or not the grid has been initialised. */
			boolean			gridCreated	= false;
			
			/* Read each line of the grid file until there are no more lines. */
			while (line != null) {
			
				/* 
				 * If reading the grid, increment the row counter and reset 
				 * the column counter. 
				 */
				if (readGrid) {
					row++;
					column = 0;
				}
				
				/* Tokenize the current line to parse it. */
				tokenizer = new StringTokenizer(line);
				
				/* Traverse each line in tokens. */
				while (tokenizer.hasMoreTokens() && !comment) {
					token = tokenizer.nextToken();
					
					/* Detect whether or not a line is a comment. */
					if (token.equals("%")) {
						comment = true;
					} else {
						
						/* Create grid. */
						if (rows > 0 && columns > 0 && !gridCreated) {
							this.grid = new Block[rows][columns];
							this.checkingGrid = new boolean[rows][columns];
							
							if (this.gameType.equals("Feeding")) {
								this.feedingRow = new Block[columns];
								emptyFeedingRow();
							}
							
							gridCreated = true;
						}
						
						/* If the readGrid flag is true, parse the grid. */
						if (readGrid) {
						
							if (token.equals("e")) {
							
								/* 
								 * If the character is an ``e'', insert an empty 
								 * block.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] = new EmptyBlock();
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new EmptyBlock();
								}

								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("b")) {
							
								/* 
								 * If the character is an ``b'', insert a blue 
								 * block.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
											= new ColouredBlock(Color.blue);
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new ColouredBlock(Color.blue);
								}
								
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("r")) {
							
								/* 
								 * If the character is an ``r'', insert a red 
								 * block.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
										= new ColouredBlock(Color.red);
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new ColouredBlock(Color.red);
								}
								
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("g")) {
							
								/* 
								 * If the character is a ``g'', insert a green 
								 * block.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
											= new ColouredBlock(Color.green);
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new ColouredBlock(Color.green);
								}
										
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("y")) {
							
								/* 
								 * If the character is a ``y'', insert a yellow 
								 * block.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
										= new ColouredBlock(Color.yellow);
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new ColouredBlock(Color.yellow);
								}
										
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("w")) {
							
								/* 
								 * If the character is a ``w'', insert a white 
								 * block.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
										= new ColouredBlock(Color.white);
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new ColouredBlock(Color.white);
								}
										
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("p")) {
							
								/* 
								 * If the character is a ``p'', insert a
								 * platform block.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] = new Platform();
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] = new Platform();
								}
										
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("i")) {
							
								/* 
								 * If the character is an ``i'', insert an
								 * indestructible block.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
										= new IndestructibleBlock();
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new IndestructibleBlock();
								}
										
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("B")) {
							
								/* 
								 * If the character is a ``B'', insert a blue 
								 * bomb.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
										= new ColourBomb(Color.blue);
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new ColourBomb(Color.blue);
								}
								
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("G")) {
							
								/* 
								 * If the character is a ``G'', insert a green 
								 * bomb.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
										= new ColourBomb(Color.green);
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new ColourBomb(Color.green);
								}
										
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("R")) {
							
								/* 
								 * If the character is a ``R'', insert a red 
								 * bomb.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
										= new ColourBomb(Color.red);
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new ColourBomb(Color.red);
								}
										
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("Y")) {
							
								/* 
								 * If the character is a ``Y'', insert a yellow 
								 * bomb.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
										= new ColourBomb(Color.yellow);
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new ColourBomb(Color.yellow);
								}
										
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("W")) {
							
								/* 
								 * If the character is a ``W'', insert a white 
								 * bomb.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
										= new ColourBomb(Color.white);
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] 
											= new ColourBomb(Color.white);
								}
										
								/* Increment the column counter. */
								column++;
								
							} else if (token.equals("S")) {
							
								/* 
								 * If the character is a ``S'', insert a super 
								 * bomb.
								 */
								if (row < this.grid.length) {
									this.grid[row][column] 
										= new SuperBomb();
								} else if (this.gameType.equals("Feeding")) {
									this.feedingRow[column] = new SuperBomb();
								}
										
								/* Increment the column counter. */
								column++;
								
							}
						}
						
						/* Parse type, rows and columns data. */
						if (token.equals("Type:") 
								&& tokenizer.hasMoreTokens()) {
								
							/* Set token to type. */
							token = tokenizer.nextToken();
							
							/* Set game type. */
							this.gameType = token;
							
						} else if (token.equals("Rows:") 
								&& tokenizer.hasMoreTokens()) {
								
							/* Set token to number of rows. */
							token = tokenizer.nextToken();
							
							/* Set number of rows. */
							rows = Integer.parseInt(token);
							
						} else if (token.equals("Columns:") 
								&& tokenizer.hasMoreTokens()) {
								
							/* Set token to number of columns. */
							token = tokenizer.nextToken();
							
							/* Set number of columns. */
							columns = Integer.parseInt(token);
							
						} else if (token.equals("Difficulty:") 
								&& tokenizer.hasMoreTokens()) {
								
							/* Set token to the difficulty level. */
							token = tokenizer.nextToken();
							
							/* Set the difficulty level. */
							setDifficulty(Integer.parseInt(token));
						
						} else if (token.equals("Score:") 
								&& tokenizer.hasMoreTokens()) {
								
							/* Set token to the score. */
							token = tokenizer.nextToken();
							
							/* Set the difficulty level. */
							setScore(Integer.parseInt(token));
						
						} else if (token.equals("Begin")) {
							
							/* Start reading the grid. */
							readGrid = true;
						}
					}
				}
				
				/* Read in the next line. */
				line = reader.readLine();
				
				/* Reset comment flag. */
				comment = false;
			}
			
		} catch (FileNotFoundException fnf) {
			System.out.println(gridFile.getName() + " was not found.");
		} catch (IOException io) {
			System.out.println("An input/output exception has occured.");
		}
	}
	
	/* Constructor. Creates a new game with the set difficulty. */
	public Grid(String gameType, int difficulty) {
		
		/* Create grids. */
		this.grid = new Block[16][12];
		this.checkingGrid = new boolean[16][12];
		
		if (gameType.equals("Feeding")) {
			this.feedingRow = new Block[12];
			emptyFeedingRow();
		}
		
		/* Set game type and difficulty. */
		setGameType(gameType);
		setDifficulty(difficulty);
		
		/* Traverse each row in the grid. */
		for (int row = 0; row < this.grid.length; row++) {
			
			/* Traverse each column in the row. */
			for (int column = 0; column < this.grid[row].length; column++) {
			
				/* 
				 * Depending on the difficulty, fill the bottom few rows of
				 * the grid.
				 */
				if (row >= (grid.length - getDifficulty())) {
					this.grid[row][column] = randomBlock();
				} else {
					this.grid[row][column] = new EmptyBlock();
				}
			}
		}
	}
		
	/* Save the game to a file. */
	public void saveGame(File gridFile) {
		try {
		
			BufferedWriter	output 	= new BufferedWriter(
					new FileWriter(gridFile));
			
			/* Write out the game type, number of rows and number of columns. */
			output.write("Type: " + getGameType() + "\n");
			output.write("Rows: " + getRows() + "\n");
			output.write("Columns: " + getColumns() + "\n");
			output.write("Difficulty: " + getDifficulty() + "\n");
			output.write("Score: " + getScore() + "\n");
			
			/* Begin writing the blocks in the grid. */
			output.write("Begin\n");
			
			/* Copy, one character at a time, from input to output. */
			/* Traverse each row in the grid. */
			for (int row = 0; row < this.grid.length; row++) {
				
				/* Traverse each column in the row. */
				for (int column = 0; column < this.grid[row].length; column++) {
				
					output.write(parseIntoSymbol(this.grid[row][column]));
				}
				
				/* Write out a new line after every row. */
				output.write("\n");
			}
			
			/* If this is a feeding game, write out the feeding row too. */
			if (getGameType().equals("Feeding")) {
				for (int column = 0; column < this.feedingRow.length; 
						column++) {
					output.write(parseIntoSymbol(this.feedingRow[column]));
				}
				
				/* Output a new line. */
				output.write("\n");
			}
			
			/* Write out ``End'' to signal the end of the grid. */
			output.write("End\n");
				
			output.flush();

		} catch (FileNotFoundException fnf) {
			System.out.println("Error, file not found.");
		} catch (IOException io) {
			System.out.println("Error, input/output exception has occured.");
		}
	}
	
	/* Parses a block and returns its symbol for output. */
	public String parseIntoSymbol(Block blockToParse) {
	
		/* Symbol. */
		String symbol = new String();
		
		/* Variable to cast coloured blocks into. */
		ColouredBlock	block;
		
		/* Variable to cast colour bombs into. */
		ColourBomb		bomb;
		
		if (blockToParse.getClass().getName().
				equals("EmptyBlock")) {
				
			/* If the block is an empty block, write out ``e''. */
			symbol = "e ";
			
		} else if (blockToParse.getClass().getName().
				equals("ColouredBlock")) {
			
			/* 
			 * If the block is a coloured block, determine its 
			 * colour.
			 */
			block = (ColouredBlock)blockToParse;
			
			if (block.getColour().equals(Color.blue)) {
			
				/* If the block is blue, write out ``b''. */
				symbol = "b ";
				
			} else if (block.getColour().equals(Color.red)) {
			
				/* If the block is red, write out ``r''. */
				symbol = "r ";
				
			} else if (block.getColour().equals(Color.green)) {
			
				/* If the block is green, write out ``g''. */
				symbol = "g ";
				
			} else if (block.getColour().equals(Color.yellow)) {
			
				/* If the block is yellow, write out ``y''. */
				symbol = "y ";
				
			} else if (block.getColour().equals(Color.white)) {
			
				/* If the block is white, write out ``w''. */
				symbol = "w ";
			}
			
		} else if (blockToParse.getClass().getName().
				equals("Platform")) {
		
			/* If the block is a platform block, write out ``p''. */
			symbol = "p ";
			
		} else if (blockToParse.getClass().getName().
				equals("IndestructibleBlock")) {
			
			/*
			 * If the block is an indestructible block, write out 
			 * ``i''.
			 */
			symbol = "i ";
			
		} else if (blockToParse.getClass().getName().
				equals("SuperBomb")) {
		
			/* If the block is a super bomb, write out ``S''. */
			symbol = "S ";
			
		} else if (blockToParse.getClass().getName().
				equals("ColourBomb")) {
		
			/* 
			 * If the block is a colour bomb, determine its 
			 * colour. 
			 */
			bomb = (ColourBomb)blockToParse;
			
			if (bomb.getColour().equals(Color.blue)) {
			
				/* If the block is blue, write out ``B''. */
				symbol = "B ";
				
			} else if (bomb.getColour().equals(Color.red)) {
				
				/* If the block is red, write out ``R''. */
				symbol = "R ";
				
			} else if (bomb.getColour().equals(Color.green)) {
			
				/* If the block is green, write out ``G''. */
				symbol = "G ";
				
			} else if (bomb.getColour().equals(Color.yellow)) {
			
				/* If the block is yellow, write out ``Y''. */
				symbol = "Y ";
				
			} else if (bomb.getColour().equals(Color.white)) {
			
				/* If the block is white, write out ``W''. */
				symbol = "W ";
				
			}
		}
		
		return symbol;
	}
	
	/* 
	 * Update the grid: remove blocks when neccessary, apply gravity, 
	 * attraction, etc. 
	 */
	public void updateGrid() {
		
		/* Traverse each row in the grid. */
		for (int row = (grid.length - 1); row >= 0; row--) {
			
			/* Traverse each column in the row. */
			for (int column = (grid[row].length - 1); column >= 0; column--) {
			
				/* 
				 * For each block, check if it needs removing and apply
				 * attraction to the whole grid.
				 */
				checkForRemoval(row, column);
				applyAttraction();
			}
		}	
		
		/* Traverse each row in the grid. */
		for (int row = (grid.length - 1); row >= 0; row--) {
			
			/* Traverse each column in the row. */
			for (int column = (grid[row].length - 1); column >= 0; column--) {
				applyGravity(row, column);
			}
		}
		
		/* If the game type is basic, check whether the game is over yet. */
		if (getGameType().equals("Basic")) {
		
			/* If there are no more possible clusters left... */
			if (numberOfClustersInGrid() < 1) {
				
				if (numberOfBlocksInGrid() < 1) {
					
					/* If there are no blocks, the game is won. */
					setGameState(WON);
					
				} else {
				
					/* If there are some blocks left, the game is lost. */
					setGameState(LOST);
					
				}
			}
		}
	}
	
	/* Returns the number of coloured blocks currently in the grid. */
	private int numberOfBlocksInGrid() {
		
		/* The number of blocks currently found in the grid. */
		int numberOfBlocksInGrid = 0;
		
		/* Traverse each row in the grid. */
		for (int row = 0; row < this.grid.length; row++) {
			
			/* Traverse each column in the row. */
			for (int column = 0; column < this.grid[row].length; column++) {
			
				/* 
				 * If the current block is a coloured block, increment the
				 * counter.
				 */
				if (this.grid[row][column].getClass().getName().
						equals("ColouredBlock")) {
					numberOfBlocksInGrid++;
				}
			}
		}
		
		return numberOfBlocksInGrid;
	}

	/*
	 * Return a random coloured block based on the difficulty setting of the 
	 * game.
	 */
	private ColouredBlock randomBlock() {
				
		int				randomBlock;
		ColouredBlock	blockToReturn = new ColouredBlock(Color.red);
		
		/* 
		 * Set up the range of the random number generator based on the 
		 * difficulty setting.
		 */
		if (getDifficulty() > 4) {
			randomBlock = generator.nextInt(5);
		} else if (getDifficulty() > 3) {
			randomBlock = generator.nextInt(4);
		} else {
			randomBlock = generator.nextInt(3);
		}
		
		/* Choose which colour block to return based on the random number. */
		switch (randomBlock) {
			case 0:
				blockToReturn = new ColouredBlock(Color.red);
				break;
			case 1:
				blockToReturn = new ColouredBlock(Color.blue);
				break;
			case 2:
				blockToReturn = new ColouredBlock(Color.green);
				break;
			case 3:
				blockToReturn = new ColouredBlock(Color.white);
				break;
			case 4:
				blockToReturn = new ColouredBlock(Color.yellow);
				break;
		}
		
		return blockToReturn;
	}
	
	/* Return the current number of different coloured blocks in the grid. */
	public int numberOfColoursInGrid() {
	
		/* Use an array list to store the different colours. */
		ArrayList colours = new ArrayList();
		
		/* Holder for the current block to be cast into. */
		ColouredBlock block;
		
		/* Traverse each row in the grid. */
		for (int row = 0; row < this.grid.length; row++) {
			
			/* Traverse each column in the row. */
			for (int column = 0; column < this.grid[row].length; column++) {
			
				/* If the current block is a coloured block. */
				if (this.grid[row][column].getClass().getName().
						equals("ColouredBlock")) {
				
					/* Cast the block into a coloured block. */
					block = (ColouredBlock)this.grid[row][column];
					
					/* If the colour is not already in the list, add it. */
					if (colours.indexOf(block.getColour()) == -1) {
						colours.add(block.getColour());
					}
				}
			}
		}
		
		return colours.size();
	}
	
	/* 
	 * Check the current block to see if it needs to be removed, if so, see
	 * if it is part of a cluster in which case, remove the whole cluster
	 * otherwise reset the block and beep to warn the user.
	 */
	private void checkForRemoval(int row, int column) {
	
		/* If a block in the grid is marked to be removed... */
		if (this.grid[row][column].toBeRemoved()) {
		
			/* If the block to be removed is a coloured block... */
			if (this.grid[row][column].getClass().getName().
					equals("ColouredBlock")) {
			
				this.numberInCluster = 1;
				this.checkingGrid[row][column] = true;
				
				/* Remove blocks of the same colour around it. */
				removeClusterFrom(row, column);
				
				/* Remove the central block itself if a cluster was found. */
				if (this.numberInCluster > 2) {
					removeBlockAt(row, column);
				} else {
					
					/* If the block was not part of a cluster, reset it. */
					this.grid[row][column].reset();
					
					/* 
					 * Emit a system beep to alert the user that this block
					 * cannot be removed.
					 */
					Toolkit.getDefaultToolkit().beep();
				}
				
				/* Give bonus points for removing a cluster. */
				if (this.numberInCluster > 10 && this.numberInCluster < 25) {
					score = score + (150 * numberOfColoursInGrid());
				} else if (this.numberInCluster > 24 
						&& this.numberInCluster < 79) {
					score = score + (500 * numberOfColoursInGrid());
				} else if (this.numberInCluster > 78 
						&& this.numberInCluster < 181) {
					score = score + (1500 * numberOfColoursInGrid());
				}
				
				/* Reset variables changed by detecting clusters. */
				this.numberInCluster = 0;
				this.checkingGrid = new boolean[getRows()][getColumns()];
				
			} else if (this.grid[row][column].getClass().getName().
					equals("ColourBomb")) {
				
				/* If the block is a colour bomb... */
				ColourBomb colourbomb = (ColourBomb)this.grid[row][column];
				
				/* Remove all of the designated colour. */
				removeAllOfColour(colourbomb.getColour());
				
				/* Remove the block itself. */
				removeBlockAt(row, column);
				
			} else if (this.grid[row][column].getClass().getName().
					equals("SuperBomb")) {
			
				/* If the block is a super bomb...*/
				SuperBomb superbomb = (SuperBomb)this.grid[row][column];
				
				int range 					= superbomb.getRange();
				int damageAreaCornerRow 	= row - range;
				int damageAreaCornerColumn 	= column - range;
				
				for (int i = damageAreaCornerRow; i 
						< (damageAreaCornerRow + ((range * 2) + 1)); i++) {
				
					for (int j = damageAreaCornerColumn; j 
							< (damageAreaCornerColumn + ((range * 2) + 1)); 
							j++) {
						
						if (i >= 0 && i < getRows() && j >= 0 
								&& j < getColumns()) {
							removeBlockAt(i, j, false);
						}
					}
				}
			}
		}
	}
	
	/* Remove all blocks of a certain colour from the grid. */
	private void removeAllOfColour(Color colour) {
	
		/* Traverse each row in the grid. */
		for (int row = 0; row < this.grid.length; row++) {
			
			/* Traverse each column in the row. */
			for (int column = 0; column < this.grid[row].length; column++) {
				
				if (this.grid[row][column].getClass().getName().
						equals("ColouredBlock")) {
					ColouredBlock block = (ColouredBlock)this.grid[row][column];
					
					if (block.getColour().equals(colour)) {
						removeBlockAt(row, column);
					}
				}
			}
		}	
	}
	
	/* Traverse grid and apply gravity where needed. */
	private void applyGravity(int row, int column) {
	
		int searchRow = row;
		
		if (this.grid[row][column].getClass().getName().equals("EmptyBlock")) {
			
			while ((searchRow - 1) >= 0 
					&& this.grid[searchRow][column].getClass().getName().
							equals("EmptyBlock")) {
				searchRow--;
			}
			
			if (searchRow >= 0 && this.grid[searchRow][column].
					subjectToGravity()) {
				this.grid[row][column] = this.grid[searchRow][column];
				this.grid[searchRow][column] = new EmptyBlock();
			}
		}
	}
	
	/* Apply attraction to the entire grid. */
	private void applyAttraction() {
		
		/* Counter for how many empty blocks have been found in a column. */
		int numberOfEmptyBlocks = 0;
		
		/* Current empty column. */
		int emptyColumn;

		/* Used to cast the column number into an int value. */
		Integer holder;
		
		/* Array list to hold each empty column found. */
		ArrayList emptyColumns = new ArrayList();
		
		/* Traverse each column in the grid. */
		for (int column = 0; column < this.grid[0].length; column++) {
		
			/* Traverse each row in the column. */
			for (int row = 0; row < this.grid.length; row++) {
			
				/* If the current block is empty, increment the counter. */
				if (grid[row][column].getClass().getName().
						equals("EmptyBlock")) {
					numberOfEmptyBlocks++;
				}
			}
			
			/* If the entire column is empty, add the column to the list. */
			if (numberOfEmptyBlocks == grid.length) {
				emptyColumns.add(new Integer(column));
			}
			
			/* Reset the number of empty blocks in the column. */
			numberOfEmptyBlocks = 0;
		}
		
		/* Go through each empty column in the list. */
		for (int i = 0; i < emptyColumns.size(); i++) {
		
			/* Cast the column into an int. */
			holder = (Integer)emptyColumns.get(i);
			emptyColumn = holder.intValue();
			
			if ((this.grid[0].length / 2) >= emptyColumn) {
			
				/* 
				 * If the column falls on the left side of the grid, move blocks
				 * right.
				 */
				moveBlocksRight(emptyColumn);
				
			} else if ((this.grid[0].length / 2) < emptyColumn) {
			
				/* 
				 * If the column falls on the right side of the grid, move
				 * blocks left.
				 */
				moveBlocksLeft(emptyColumn);
			}
		}
	}
	
	/* Move each block in a column right. */
	private void moveBlocksRight(int column) {

		/* Traverse each row in the grid. */
		for (int row = (this.grid.length - 1); row >= 0; row--) {
		
			if (column - 1 >= 0) {
			
				if (this.grid[row][column].getClass().getName().
						equals("EmptyBlock")) {
				
					if (!this.grid[row][column-1].getClass().getName().
							equals("EmptyBlock")) {
					
						if (this.grid[row][column-1].subjectToAttraction()) {
							this.grid[row][column] = this.grid[row][column-1];
							this.grid[row][column-1] = new EmptyBlock();
						}
					}
				}
			}
		}
	}
	
	/* Move each block in a column left. */
	private void moveBlocksLeft(int column) {

		/* Traverse each row in the grid. */
		for (int row = 0; row < this.grid.length; row++) {
		
			if (column + 1 < getColumns()) {
			
				if (this.grid[row][column].getClass().getName().
						equals("EmptyBlock")) {
				
					if (!this.grid[row][column+1].getClass().getName().
							equals("EmptyBlock")) {
					
						if (this.grid[row][column+1].subjectToAttraction()) {
						
							this.grid[row][column] = this.grid[row][column+1];
							this.grid[row][column+1] = new EmptyBlock();
						}
					}
				}
			}
		}
	}
	
	/* Removes block at given co-ordinates and increments score accordingly. */
	private void removeBlockAt(int row, int column) {	
	
		if (this.grid[row][column].getClass().getName().
				equals("ColouredBlock")) {
			this.score = this.score + 5;
		}
		
		this.grid[row][column] = new EmptyBlock();
	}
	
	/* Removes block at given co-ordinates and increments score accordingly. */
	private void removeBlockAt(int row, int column, boolean score) {	
	
		if (score) {
			if (this.grid[row][column].getClass().getName().
					equals("ColouredBlock")) {
				this.score = this.score + 5;
			}
		}
		
		this.grid[row][column] = new EmptyBlock();
	}
	
	/* Returns the number of clusters currently in the grid. */
	public int numberOfClustersInGrid() {
		
		/* Set up detection grid. */
		this.detectionCheckingGrid = new boolean[getRows()][getColumns()];
		
		/* The number of clusters in the grid. */
		int numberOfClusters = 0;
		
		/* Traverse each row in the grid. */
		for (int row = 0; row < this.grid.length; row++) {
			
			/* Traverse each column in the row. */
			for (int column = 0; column < this.grid[row].length; column++) {
			
				if (this.grid[row][column].getClass().getName().
						equals("ColouredBlock")) {
				
					this.detectionNumberInCluster = 1;
					this.detectionCheckingGrid[row][column] = true;
				
					/* 
					 * If the block is part of a cluster, increment the 
					 * counter. 
					 */
					if (blockIsACluster(row, column)) {
						numberOfClusters++;
						
						/* Reset the counter. */
						this.detectionNumberInCluster = 0;
					}
				}
			}
		}
		
		/* Reset the checking grid. */
		this.detectionCheckingGrid = new boolean[getRows()][getColumns()];
		
		return numberOfClusters;
	}
	
	/* 
	 * Detects a cluster of blocks and returns true if one is found from the
	 * current block.
	 */
	private boolean blockIsACluster(int row, int column) {

		ColouredBlock	centreBlock = (ColouredBlock)this.grid[row][column];
		Color			colour		= centreBlock.getColour();
		
		/* Check block to the right. */
		if (column+1 < this.grid[column].length) {
		
			if (this.grid[row][column+1].getClass().getName().
					equals("ColouredBlock")) {
			
				ColouredBlock rightBlock 
						= (ColouredBlock)this.grid[row][column+1];
				
				/*
				 * If the block is the right colour and has not been checked 
				 * before... 
				 */
				if (rightBlock.getColour().equals(colour) 
						&& !this.detectionCheckingGrid[row][column+1]) {
					
					/* Mark as checked. */
					this.detectionCheckingGrid[row][column+1] = true;
					
					/* Increment the counter. */
					this.detectionNumberInCluster++;
										
					/* Check from this point onwards. */
					blockIsACluster(row, column+1);
				}
			}
		}	
		
		/* Check block to the left. */
		if (column-1 >= 0) {
			
			if (this.grid[row][column-1].getClass().getName().
					equals("ColouredBlock")) {
			
				ColouredBlock	leftBlock 
						= (ColouredBlock)this.grid[row][column-1];
				
				/*
				 * If the block is the right colour and has not been checked 
				 * before... 
				 */
				if (leftBlock.getColour().equals(colour) 
						&& !this.detectionCheckingGrid[row][column-1]) {
					
					/* Mark as checked. */
					this.detectionCheckingGrid[row][column-1] = true;
					
					/* Increment the counter. */
					this.detectionNumberInCluster++;
					
					/* Check from this point onwards. */
					blockIsACluster(row, column-1);
				}
			}
		}	
		
		/* Check block above. */
		if (row-1 >= 0) {
			
			if (this.grid[row-1][column].getClass().getName().
					equals("ColouredBlock")) {
			
				ColouredBlock	aboveBlock 
						= (ColouredBlock)this.grid[row-1][column];
				
				/*
				 * If the block is the right colour and has not been checked 
				 * before... 
				 */
				if (aboveBlock.getColour().equals(colour) 
						&& !this.detectionCheckingGrid[row-1][column]) {
					
					/* Mark as checked. */
					this.detectionCheckingGrid[row-1][column] = true;
					
					/* Increment the counter. */
					this.detectionNumberInCluster++;
					
					/* Check from this point onwards. */
					blockIsACluster(row-1, column);
				}
			}
		}	
		
		/* Check block below. */
		if (row+1 < grid.length) {
			
			if (this.grid[row+1][column].getClass().getName().
					equals("ColouredBlock")) {
			
				ColouredBlock	belowBlock 
						= (ColouredBlock)this.grid[row+1][column];
			
				/*
				 * If the block is the right colour and has not been checked 
				 * before... 
				 */
				if (belowBlock.getColour().equals(colour) 
						&& !this.detectionCheckingGrid[row+1][column]) {
					
					/* Mark as checked. */
					this.detectionCheckingGrid[row+1][column] = true;
					
					/* Increment the counter. */
					this.detectionNumberInCluster++;
					
					/* Check from this point onwards. */
					blockIsACluster(row+1, column);
				}
			}
		}	
		
		/* If more than two blocks were detected as connected, return true. */
		if (this.detectionNumberInCluster >= 3) {
			return true;
		} else {
			return false;
		}
	}
	
	/* 
	 * Detects and removes a cluster of blocks of the same colour if three 
	 * or more connected ones exist.
	 */
	private void removeClusterFrom(int row, int column) {
		boolean deleteBlockToRight		= false;
		boolean deleteBlockToLeft		= false;
		boolean deleteBlockAbove		= false;
		boolean deleteBlockBelow		= false;
		
		boolean deleteSuperBombToRight	= false;
		boolean deleteSuperBombToLeft	= false;
		boolean deleteSuperBombAbove	= false;
		boolean deleteSuperBombBelow	= false;
		
		ColouredBlock	centreBlock = (ColouredBlock)grid[row][column];
		Color			colour		= centreBlock.getColour();
		
		/* Check block to the right. */
		if (column+1 < this.grid[column].length) {
		
			if (this.grid[row][column+1].getClass().getName().
					equals("ColouredBlock")) {
			
				ColouredBlock rightBlock 
						= (ColouredBlock)this.grid[row][column+1];
				
				/*
				 * If the block is the right colour and has not been checked 
				 * before... 
				 */
				if (rightBlock.getColour().equals(colour) 
						&& !this.checkingGrid[row][column+1]) {
					
					/* Mark as checked. */
					this.checkingGrid[row][column+1] = true;
					
					/* Increment the counter. */
					this.numberInCluster++;
					
					/* Check from this point onwards. */
					removeClusterFrom(row, column+1);
					
					deleteBlockToRight = true;
				}
			} else if (this.grid[row][column+1].getClass().getName().
					equals("SuperBomb")) {
				
				deleteSuperBombToRight = true;
			}
		}	
		
		/* Check block to the left. */
		if (column-1 >= 0) {
			
			if (this.grid[row][column-1].getClass().getName().
					equals("ColouredBlock")) {
			
				ColouredBlock	leftBlock 
						= (ColouredBlock)this.grid[row][column-1];
				
				/*
				 * If the block is the right colour and has not been checked 
				 * before... 
				 */
				if (leftBlock.getColour().equals(colour) 
						&& !this.checkingGrid[row][column-1]) {
					
					/* Mark as checked. */
					this.checkingGrid[row][column-1] = true;
					
					/* Increment the counter. */
					this.numberInCluster++;
					
					/* Check from this point onwards. */
					removeClusterFrom(row, column-1);
					
					deleteBlockToLeft = true;
				}
			} else if (this.grid[row][column-1].getClass().getName().
					equals("SuperBomb")) {
				
				deleteSuperBombToLeft = true;
			}
		}	
		
		/* Check block above. */
		if (row-1 >= 0) {
			
			if (this.grid[row-1][column].getClass().getName().
					equals("ColouredBlock")) {
			
				ColouredBlock	aboveBlock 
						= (ColouredBlock)this.grid[row-1][column];
				
				/*
				 * If the block is the right colour and has not been checked 
				 * before... 
				 */
				if (aboveBlock.getColour().equals(colour) 
						&& !this.checkingGrid[row-1][column]) {
					
					/* Mark as checked. */
					this.checkingGrid[row-1][column] = true;
					
					/* Increment the counter. */
					this.numberInCluster++;
					
					/* Check from this point onwards. */
					removeClusterFrom(row-1, column);
					
					deleteBlockAbove = true;
				}
			} else if (this.grid[row-1][column].getClass().getName().
					equals("SuperBomb")) {
				
				deleteSuperBombAbove = true;
			}
		}	
		
		/* Check block below. */
		if (row+1 < this.grid.length) {
			
			if (this.grid[row+1][column].getClass().getName().
					equals("ColouredBlock")) {
			
				ColouredBlock	belowBlock 
						= (ColouredBlock)this.grid[row+1][column];
			
				/*
				 * If the block is the right colour and has not been checked 
				 * before... 
				 */
				if (belowBlock.getColour().equals(colour) 
						&& !this.checkingGrid[row+1][column]) {
					
					/* Mark as checked. */
					this.checkingGrid[row+1][column] = true;
					
					/* Increment the counter. */
					this.numberInCluster++;
					
					/* Check from this point onwards. */
					removeClusterFrom(row+1, column);
					
					deleteBlockBelow = true;
				}
			} else if (this.grid[row+1][column].getClass().getName().
					equals("SuperBomb")) {
				
				deleteSuperBombBelow = true;
			}
		}	
		
		/* Delete blocks as necessary. */
		if (this.numberInCluster > 2) {
			if (deleteBlockToRight || deleteSuperBombToRight) {
				removeBlockAt(row, column+1);
			}
			if (deleteBlockToLeft || deleteSuperBombToLeft) {
				removeBlockAt(row, column-1);
			}
			if (deleteBlockAbove || deleteSuperBombAbove) {
				removeBlockAt(row-1, column);
			}
			if (deleteBlockBelow || deleteSuperBombBelow) {
				removeBlockAt(row+1, column);
			}
		}
	}
	
		
	/* 
	 * Add a new random block to the feeding row; if the feeding row is full
	 * add the feeding row to the playing field. Returns boolean value to
	 * indicate whether a new row has been added or not (so that the playing
	 * field can redraw only when necessary).
	 */
	public boolean addToFeedingRow() {
	
		/* Index of the feeding row. */
		int i = 0;
		
		/* Traverse to the first empty space in the feeding row. */
		while (i < this.feedingRow.length 
				&& !this.feedingRow[i].getClass().getName().
					equals("EmptyBlock")) {
			i++;
		}
		
		if (i >= feedingRow.length) {
			
			/* 
			 * If the feeding row is full, add the feeding row to the playing
			 * field.
			 */
			addFeedingRowToGrid();
			
			/* Empty the feeding row. */
			emptyFeedingRow();
			return true;
			
		} else {
		
			/* Add a random block to the feeding row. */
			this.feedingRow[i] = randomBlock();
			return false;
		}
	}
	
	/* Empty the feeding row. */
	private void emptyFeedingRow() {
		for (int column = 0; column < this.feedingRow.length; column++) {
			feedingRow[column] = new EmptyBlock();
		}
	}
	
	/* Add the feeding row to the playing field. */
	public void addFeedingRowToGrid() {
	
		/* Traverse each row in the grid. */
		for (int row = 0; row < this.grid.length; row++) {
			
			/* Traverse each column in the row. */
			for (int column = 0; column < this.grid[row].length; column++) {
			
				/* If the playing field is full the game is lost. */
				if (row == 0 && !this.grid[row][column].getClass().getName().
						equals("EmptyBlock")) {
					setGameState(LOST);
				}
				
				/* Move all blocks up one. */
				if (row-1 >= 0) {
					this.grid[row-1][column] = this.grid[row][column];
				}
				
				/* Add the feeding row to the grid. */
				if (row == (this.grid.length - 1)) {
				
					this.grid[row][column] = this.feedingRow[column];
				}
			}
		}	
	}
}