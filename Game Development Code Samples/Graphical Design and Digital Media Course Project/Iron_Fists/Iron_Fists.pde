/* //<>//
Final Project for Graphical Design and Digital Media class
The Video Game: Iron Fists
Pledged by Mykola Herasymovych, 12.9.2016

Instruction:
Use controls on the right of the keyboard to control Player 1 and on the left to control Player 2.
You can see the control keys on the menu screen under each player.
You can walk by holding 'walk left' or 'walk right'. You can run by additionally holding 'run' key.
You can jump by pressing 'jump' key. You can attack by pressing 'attack' key. 
Each successful attack decreases opponent's life by 1 and score by 5, increasing player's score by 5.
You can parry opponent's attack by pressing 'parry' key. If your opponent attacks you when you're parrying,
his attack will be unsuccessful and you will earn 3 points.
You can celebrate by holding 'celebrate' key. It's just a funny animation.
You can die by pressing 'die' key. Don't die unless you really really want to!
You can call menu screen by pressing 'pause' key.
You can change player's color by clicking the button under players in the start menu.
You can turn on/off sound by clicking the sound/mute icon in the lower left corner of the screen.
You can start, continue or restart game by clicking the buttonsin the center of the menu screen.
You can see scores and lives of each player in the upper corners of the screen.
Enjoy the game!
*/


// THE CODE/////////////////////////////////////////////////////////////////////////////////////
// Import packages
import processing.sound.*;

// Declare variables ///////////////////////////////////////////////////////////////////////////
// Declare sound variabels
SoundFile themeMusic, battleMusic, clickSound, jumpSound, attackSound, parrySound, hitSound, deathSound, celebrateSound, victoryMusic;

// Declare game title string and font
String title = "Iron Fists";
PFont font;

// Declare game logic variables
boolean set = false; // if he program is set up
boolean sound = true; // if sound is turned on
boolean start = false; // if the game has started
boolean pause = false; // if the game is paused
boolean victory = false; // if there is a winner

// Declare buttons
Button soundButton, startButton, restartButton, continueButton, p1ColorChangeButton, p2ColorChangeButton;

// Declare background and platform images
PImage background;

int platformNum = 4;
PImage[] platformImages = new PImage[platformNum];

// Declare platform objects
Platform[] platforms = new Platform[platformNum];

// Declare player objects
Player player1, player2;

// Declare player animation images
int imageIndex = 0;
int maxImagesIdle = 11;
PImage[] playerImagesIdle = new PImage[maxImagesIdle];
int maxImagesCelebrate = 9;
PImage[] playerImagesCelebrate = new PImage[maxImagesCelebrate];
int maxImagesJump = 10;
PImage[] playerImagesJump = new PImage[maxImagesJump];
int maxImagesRun = 10;
PImage[] playerImagesRun = new PImage[maxImagesRun];
int maxImagesWalk = 10;
PImage[] playerImagesWalk = new PImage[maxImagesWalk];
int maxImagesAttack = 10;
PImage[] playerImagesAttack = new PImage[maxImagesAttack];
int maxImagesParry = 10;
PImage[] playerImagesParry = new PImage[maxImagesParry];
int maxImagesDie = 9;
PImage[] playerImagesDie = new PImage[maxImagesDie];
PImage playerImagesHit;

// Declare details images
PImage fist, life, cut, parry, portal, soundIcon, noSoundIcon;

// Declare window sizes, gravity and menu coordinate
float windowWidth, windowHeight, gravity, menuY;

// setup /////////////////////////////////////////////////////////////////////////////////////
void setup() {
  // Set size, frame rate and modes
  //fullscreen(P2D); // you can try fullscreen, but the program functionality may suffer, if your resolution is too different from the original one. 
  size(900, 600, P2D); // original screen size
  frameRate(60);
  rectMode(CENTER);
  imageMode(CENTER);
  
  // Define font
  font = createFont("Showcard Gothic", 50);
  textFont(font);
  
  // Define window sizes and gravity. 
  // In some cases Processing doesn't recognize default width and height variables, but declared variables work well
  windowWidth = width;
  windowHeight = height;
  gravity = windowHeight / 600;
}


// draw ////////////////////////////////////////////////////////////////////////////////////
void draw() {
  
  // Since all the setups take too much time, Processing crashes if they are performed in setup. 
  // Thus, all the setups are performed in the draw method only once, when the program starts
  if( !set ) {
    setupOnce();
    set = true;
    themeMusic.loop();
  }
  
  // Display the background
  // Weird but Processing slows down if there is no white background set
  background(255);
  drawBackground();                         
  
  // Display platforms
  for (int i = 0; i < platforms.length; i++) {
    platforms[i].display();
  }
  
  // Display menu and sound/mute image
  displayMenu();
  displaySound();
  
  // Move and display players if not paused
  if (!pause) {
    player1.move();
    player1.setEdges();
    player1.display();
    player2.display();
    player2.move();
    player2.setEdges();
    
    // Display player's health and score and turn on fighting if the game has started
    if (start) {
      player1.fight(player2);
      player1.displayStats();
      player2.fight(player1);
      player2.displayStats();
    }
  }
}

// Define other methods ///////////////////////////////////////////////////////////////////////////

// Define mouse clicks
void mousePressed() {
  
  // Start button click: start the game and change to battle music
  if (startButton.pressCheck() & !start & !victory) {
    clickSound.play();
    start = true;
    themeMusic.stop();
    battleMusic.loop();
  } 
  // Continue button click: turn off pause mode and change to battle music
  else if (continueButton.pressCheck() & start & pause & !victory) {
    clickSound.play();
    pause = false;
    themeMusic.stop();
    battleMusic.loop();
  } 
  // Restart button click: set up new game, turn off start and pause modes and change to theme music
  else if ((restartButton.pressCheck() & start & pause) | (restartButton.pressCheck() & victory)) {
    clickSound.play();
    victoryMusic.stop();
    themeMusic.play();
    newGame();
    pause = false;
    start = false;
  } 
  // Player 1 Change Color button
  else if (p1ColorChangeButton.pressCheck() & !start & !victory) {
    clickSound.play();
    player1.c = color(random(255), random(255), random(255));
  } 
  // Player 2 Change Color button
  else if (p2ColorChangeButton.pressCheck() & !start & !victory) {
    clickSound.play();
    player2.c = color(random(255), random(255), random(255));
  } 
  // Sound/mute button
  else if (soundButton.pressCheck()) {
    clickSound.play();
    if (sound) {
      sound = false;
      themeMusic.amp(0);
      battleMusic.amp(0);
      clickSound.amp(0);
      jumpSound.amp(0);
      attackSound.amp(0);
      parrySound.amp(0);
      hitSound.amp(0);
      deathSound.amp(0);
      celebrateSound.amp(0);
      victoryMusic.amp(0);
    } else {
      sound = true;
      themeMusic.amp(1);
      battleMusic.amp(1);
      clickSound.amp(1);
      jumpSound.amp(1);
      attackSound.amp(1);
      parrySound.amp(1);
      hitSound.amp(1);
      deathSound.amp(1);
      celebrateSound.amp(1);
      victoryMusic.amp(1);
    }
  }
}

// Define key press
void keyPressed() {
  switch(keyCode) {
    //  Set control buttons for Player 1
    case RIGHT: player1.right = true; break; // Activate left movement
    case LEFT: player1.left = true; break; // Activate right movement
    case UP: player1.up = true; break; // Activate jump
    case 128: player1.isRunning = true; break; // Activate running
    case 133: if (!player1.isParrying & !player1.isCelebrating) {
      player1.isAttacking = true; 
      player1.isRunning = false;
    } // Activate attacking
    break;
    case 136: if (!player1.isAttacking & !player1.isCelebrating) {
      player1.isParrying = true; 
      player1.isRunning = false;
    } // Activate parrying
    break;
    case 132: if (!player1.dead & !player1.isCelebrating & start & !pause) {
      player1.dead = true; 
      player1.imageIndex = 0;
      victory = true;
      player2.isCelebrating = true;
    } // Activate death
    break;
    case 134: player1.isCelebrating = true; // Activate celebrating
    celebrateSound.play();
    break;
    case 137: if (!pause & start & !victory) { // Bring the pause menu
      pause = true;
      battleMusic.stop();
    } else if (pause & start & !victory) { // Move the pause menu away
      pause = false;
      battleMusic.loop();
    }
    break;
    
    // Set controls for Player 2 (analogically to the ones of Player 1)
    case 'D': player2.right = true; break;
    case 'A': player2.left = true; break;
    case 'W': player2.up = true; break;
    case ' ': player2.isRunning = true; break;
    case 'F': if (!player2.isParrying & !player2.isCelebrating) {
      player2.isAttacking = true; 
      player2.isRunning = false;
    }
    break;
    case 'G': if (!player2.isAttacking & !player2.isCelebrating) {
      player2.isParrying = true; 
      player2.isRunning = false;
    }
    break;
    case 'Q': if (!player2.dead & !player2.isCelebrating & start & !pause) {
      player2.dead = true; 
      player2.imageIndex = 0; 
      victory = true;
      player1.isCelebrating = true;
    }
    break;
    case 'E': player2.isCelebrating = true; 
    celebrateSound.play();
    break;
    case 'P': if (!pause & start & !victory) {
      pause = true;
      battleMusic.stop();
    } else if (pause & start & !victory) {
      pause = false;
      battleMusic.loop();
    }
    break;
  }
}

// Define key release
void keyReleased() {
  switch(keyCode) {
    // Set controls for Player 1
    case RIGHT: player1.right = false; break; // Deactivate right movement
    case LEFT: player1.left = false; break; // Deactivate left movement
    case UP: player1.up = false; break; // Deactivate jump
    case 128: player1.isRunning = false; break; // Deactivate running
    case 134: if (!player2.dead) player1.isCelebrating = false; // Deactivate celebrating
    celebrateSound.stop();
    break;

    // Set controls for Player 2 (analogically to the ones for Player 1)    
    case 'D': player2.right = false; break;
    case 'A': player2.left = false; break;
    case 'W': player2.up = false; break;
    case ' ': player2.isRunning = false; break;
    case 'E':if (!player1.dead) player2.isCelebrating = false; 
    celebrateSound.stop();
    break;
  }
}

// Load background image
void loadBackgrounds() {
  background = loadImage("Background.jpg");
}

// Load platform images
void loadPlatformImages() {
  for (int i = 0; i < platformImages.length; i ++) {
    platformImages[i] = loadImage("Platform" + i + ".png");
  }
}

// Define background display function 
void drawBackground() {
  image(background, width * 0.5, height * 0.5, width, height);  
}

// Load player animation images
void loadPlayerImageArray() {
  for (int i = 0; i < playerImagesIdle.length; i++) {
    playerImagesIdle[i] = loadImage("SilverKnight_entity_000_Idle_00" + i + ".png");
  }
  for (int i = 0; i < playerImagesCelebrate.length; i++) {
    playerImagesCelebrate[i] = loadImage("SilverKnight_entity_000_summon_000_00" + i + ".png");
  }
  for (int i = 0; i < playerImagesJump.length; i++) {
    playerImagesJump[i] = loadImage("SilverKnight_entity_000_jump_00" + i + ".png");
  }
  for (int i = 0; i < playerImagesRun.length; i++) {
    playerImagesRun[i] = loadImage("SilverKnight_entity_000_run_00" + i + ".png");
  }
  for (int i = 0; i < playerImagesWalk.length; i++) {
    playerImagesWalk[i] = loadImage("SilverKnight_entity_000_walk_00" + i + ".png");
  }
  for (int i = 0; i < playerImagesAttack.length; i++) {
    playerImagesAttack[i] = loadImage("SilverKnight_entity_000_basic attack style 2_00" + i + ".png");
  }
  for (int i = 0; i < playerImagesParry.length; i++) {
    playerImagesParry[i] = loadImage("SilverKnight_entity_000_basic attack 1_00" + i + ".png");
  }
  for (int i = 0; i < playerImagesDie.length; i++) {
    playerImagesDie[i] = loadImage("SilverKnight_entity_000_dead front_00" + i + ".png");
  }
  playerImagesHit = loadImage("SilverKnight_entity_000_hit back_000.png");
}

// Load details images
void loadDetailImages() {
  fist = loadImage("Fist1.png");
  life = loadImage("head.png");
  cut = loadImage("Cut.png");
  parry = loadImage("Parry.png");
  portal = loadImage("Portal.png");
  soundIcon = loadImage("Sound.png");
  noSoundIcon = loadImage("NoSound.png");
}

// Load sound files
void loadSounds() {
  themeMusic = new SoundFile(this, "ThemeMusic.mp3");
  battleMusic = new SoundFile(this, "BattleMusic.wav");
  clickSound = new SoundFile(this, "Click.wav");
  jumpSound = new SoundFile(this, "Jump.mp3");
  attackSound = new SoundFile(this, "Attack.wav");
  parrySound = new SoundFile(this, "Parry.flac");
  hitSound = new SoundFile(this, "Scream.wav");
  deathSound = new SoundFile(this, "Death.wav");
  celebrateSound = new SoundFile(this, "Celebrate.flac");
  victoryMusic = new SoundFile(this, "Victory.mp3");
  
  celebrateSound.rate(2);
}

// Define menu display method
void displayMenu() {
  
  // Limit menu movement
  menuY = constrain(menuY, -height, 0);
  
  // Translate to current menu position 
  pushMatrix();
  translate(0, menuY);
  
  // Draw menu rectangle
  stroke(255);
  fill(255, 100);
  rect(width * 0.5, height * 0.5, width * 0.85, height * 0.85, width * 0.05);
  
  // Display the title and controls or victory message conditional on the game state
  displayTitle();
  if (!victory) {
    displayInfo();
  } else {
    displayVictoryMessage();
  }
  
  // Display buttons conditional on the game state
  if (!start & !victory) {
    startButton.display();
  } else if (start & pause & !victory) {
    restartButton.display();
    continueButton.display();
  } else if(victory) {
    restartButton.display();
  }
  
  if (!start) {
  p1ColorChangeButton.display();
  p2ColorChangeButton.display();
  }
  
  popMatrix();
  
  // Move menu conditional on the game state
  if (start & !pause & !victory) {
    menuY -= 30;
  } else if (pause & !victory) {
    menuY += 30;
  } else if (victory) {
    menuY += 5;
  }
}

// Define method to set variables only once when the program is started
void setupOnce() {
  
  // Load images
  loadBackgrounds();
  loadPlatformImages();
  loadPlayerImageArray();
  loadDetailImages();
  loadSounds();
  
  // Define platform objects
  platforms[0] = new Platform(platformImages[0], width * 0.5, height * 0.95, width * 1.1, height * 0.25);
  platforms[1] = new Platform(platformImages[1], width * 0.5, height * 0.25, width * 0.2, height * 0.2);
  platforms[2] = new Platform(platformImages[2], width * 0.25, height * 0.55, width * 0.3, height * 0.2);
  platforms[3] = new Platform(platformImages[3], width * 0.75, height * 0.55, width * 0.3, height * 0.2);
  
  // Define button objects
  soundButton = new Button("Sound", windowWidth * (width / 900) * 0.02, height * 0.96, width * 0.03, height * 0.06);
  startButton = new Button("Start", windowWidth * (width / 900) * 0.5, height * 0.5, width * 0.03, width * 0.035);
  restartButton = new Button("Restart", windowWidth * (width / 900) * 0.5, height * 0.54, width * 0.03, width * 0.035);
  continueButton = new Button("Continue", windowWidth * (width / 900) * 0.5, height * 0.47, width * 0.03, width * 0.035);
  p1ColorChangeButton = new Button("Change P1 Color", windowWidth * (width / 900) * 0.76, height * 0.55, width * 0.02, width * 0.025);
  p2ColorChangeButton = new Button("Change P2 Color", windowWidth * (width / 900) * 0.24, height * 0.55, width * 0.02, width * 0.025);
  
  // Start a new game
  newGame();
}

// Define new game method
void newGame(){
  // Set victory to false and renew player objects
  victory = false;
  player1 = new Player(color(255, 100, 100), windowWidth * 0.76, platforms[3].upBorder - playerImagesIdle[0].height * (windowHeight / 600) * 0.14,1);
  player2 = new Player(color(170, 170, 255), windowWidth * 0.24, platforms[2].upBorder - playerImagesIdle[0].height * (windowHeight / 600) * 0.14,2);
}

// Define method to display title using acr-text technique
void displayTitle() {

  // We must keep track of our position along the curve
  float r = windowWidth * 0.23;
  float arclength = 0;
  textSize(width * (width / 900) * 0.058);
  textAlign(CENTER);
  
  // For every box
  for (int i = 0; i < title.length (); i ++ ) {

    // The character and its width
    char currentChar = title.charAt(i);
    // Instead of a constant width, we check the width of each character.
    float w = textWidth(currentChar); 
    // Each box is centered so we move half the width
    arclength += w/2;

    // Angle in radians is the arclength divided by the radius
    // Starting on the left side of the circle by adding PI
    float theta = PI * 1.3 + arclength / r;

    pushMatrix();
    translate(width/2, height/2);
    // Polar to Cartesian conversion allows us to find the point along the curve. See Chapter 13 for a review of this concept.
    translate(r*cos(theta), r*sin(theta)); 
    // Rotate the box (rotation is offset by 90 degrees)
    rotate(theta + PI/2); 

    // Display the character
    fill(255, 10, 0);
    text(currentChar, 0, 0);

    popMatrix();

    // Move halfway again
    arclength += w/2;
  }
  
  // Display emblem image
  image(fist, width * 0.5, height * 0.3, width * 0.2, height * 0.25);
}

// Define method to display controls
void displayInfo() {
  // Central column with actions
  textSize(width * 0.018);
  textAlign(CENTER);
  fill(50);
  text("- walk left -", width * 0.5, height * 0.6);
  text("- walk right -", width * 0.5, height * 0.64);
  text("- jump -", width * 0.5, height * 0.68);
  text("- run -", width * 0.5, height * 0.72);
  text("- attack -", width * 0.5, height * 0.76);
  text("- parry -", width * 0.5, height * 0.8);
  text("- celebrate -", width * 0.5, height * 0.84);
  text("- die -", width * 0.5, height * 0.88);
  text("- pause -", width * 0.5, height * 0.92);
  
  // Left column with controls for the left (second) player
  textSize(width * 0.021);
  text("A", width * 0.24, height * 0.6);
  text("D", width * 0.24, height * 0.64);
  text("W", width * 0.24, height * 0.68);
  text("space", width * 0.24, height * 0.72);
  text("F", width * 0.24, height * 0.76);
  text("G", width * 0.24, height * 0.8);
  text("E", width * 0.24, height * 0.84);
  text("Q", width * 0.24, height * 0.88);
  text("P", width * 0.24, height * 0.92);
  
  // Right column with controls for the right (first) player
  textSize(width * 0.021);
  text("left arrow", width * 0.76, height * 0.6);
  text("right arrow", width * 0.76, height * 0.64);
  text("up arrow", width * 0.76, height * 0.68);
  text("Num 0", width * 0.76, height * 0.72);
  text("Num 5", width * 0.76, height * 0.76);
  text("Num 8", width * 0.76, height * 0.8);
  text("Num 6", width * 0.76, height * 0.84);
  text("Num 4", width * 0.76, height * 0.88);
  text("Num 9", width * 0.76, height * 0.92);
}

// Define method to display victory message stating the winner and their score
void displayVictoryMessage() {
  textSize(width * 0.03);
  textAlign(CENTER);
  
  if (player2.dead == true) {
    text("Congratulations! Player 1 won with score " + player1.score, width * 0.5, height * 0.65);
  } else if (player1.dead == true) {
    text("Congratulations! Player 2 won with score " + player2.score, width * 0.5, height * 0.65);  
  }
}

// Define method to fdisplay sound/mute icons
void displaySound() {
  image(soundIcon, 0.02 * width, 0.96 * height, 0.03 * width, 0.06 * height);
  if (!sound) image(noSoundIcon, width * 0.022, height * 0.96, width * 0.04, width * 0.04);
}