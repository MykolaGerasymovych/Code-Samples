// Declare Player class
class Player {
  // Define local variables
  PImage image;
  color c;
  int playerNumber, score, hp;
  float x, y, px, py, w, h, xSpeed, ySpeed, xSpeedMax, ySpeedMax, accel, imageIndex, attackTime, playerRange, attackRange, portalAlpha, cutAlpha, parryAlpha;
  boolean right, left, up, invert, isCelebrating, isAttacking, isParrying, isHit, isJumping, isRunning, dead;
  
  // Constructor
  Player(color c_, float x_, float y_, int playerNumber_) {
    c = c_;
    x = x_;
    y = y_;
    px = x_;
    py = y_;
    w = 84 * (windowWidth / 900);
    h = 102 * (windowHeight / 600);
    xSpeed = 0;
    ySpeed = 0;
    xSpeedMax = (windowWidth / 900) * 2;
    ySpeedMax = (windowHeight / 600) * 20;
    accel = (windowWidth / 900) * 2;
    score = 0;
    hp = 5;
    playerNumber = playerNumber_;
    playerRange = playerImagesAttack[int(attackTime)].width * (windowWidth / 900) * 0.15; // Range of taking damage
    attackRange = playerImagesAttack[int(attackTime)].width * (windowWidth / 900) * 0.25; // Range of attack
    invert = boolean(playerNumber - 1); // If player moves in the right direction
    isJumping = true;
    isRunning = false;
    // Detail effects variables
    portalAlpha = 255;
    cutAlpha = 0;
    parryAlpha = 0;
  }
  
  // Define display method
  void display() {
    // Translate to the current player's position
    pushMatrix();
    translate(x, y);
    // If the player moves to the right, reflect the image
    if (invert) scale(-1, 1);
    
    // Draw a portal when a new player is summoned
    tint(255, portalAlpha);
    image(portal, 0, 0, w, h);
    noTint();
    
    // Paint player with the chosen color
    tint(c);
    
    // If player is in Hit state, display Hit image for 3 counts
    if (isHit) {
      image(playerImagesHit, playerImagesHit.width * (windowWidth / 900) * 0.05, -playerImagesHit.height * (windowHeight / 600) * 0.02, playerImagesHit.width * (windowWidth / 900) * 0.25, playerImagesHit.height * (windowHeight / 600) * 0.25);
      if (imageIndex == 0 & !dead) {
        hitSound.play();
      } else if (imageIndex > 3) {
        isHit = false;
        imageIndex = 0;
      }
    } 
    // If player is in Attacking state, loop through the attack images once and play attack sound  
    else if (isAttacking & !dead & !isParrying & !isRunning) {
      if (attackTime == 3) {
        attackSound.play();
      } else if (attackTime > 9) {
        attackTime = 0;
        imageIndex = 0;
        isAttacking = false;
      }
      image(playerImagesAttack[int(attackTime)], -playerImagesAttack[int(attackTime)].width * (windowWidth / 900) * 0.032, -playerImagesAttack[int(attackTime)].height * (windowHeight / 600) * 0.012, playerImagesAttack[int(attackTime)].width * (windowWidth / 900) * 0.25, playerImagesAttack[int(attackTime)].height * (windowHeight / 600) * 0.25);
      attackTime += 0.25;
    } 
    // If player is in Parrying state, loop through the parry images once and play parry  sound
    else if (isParrying & !dead & !isAttacking & !isRunning) {
      if (attackTime == 3) {
        parrySound.play();
      } else if (attackTime > 9) {
        attackTime = 0;
        imageIndex = 0;
        isParrying = false;
      }
      image(playerImagesParry[int(attackTime)], -playerImagesParry[int(attackTime)].width * (windowWidth / 900) * 0.015, 0, playerImagesParry[int(attackTime)].width * (windowWidth / 900) * 0.25, playerImagesParry[int(attackTime)].height * (windowHeight / 600) * 0.25);
      attackTime += 0.25;
    } 
    // If player is in Dead state, loop through the death images once, play death sound and change to the victory music
    else if (dead) {
      if (imageIndex == 1) {
        battleMusic.stop();
        deathSound.play();
        victoryMusic.loop();
      } else if (imageIndex > 8) {
        imageIndex = 8;
      }
      image(playerImagesDie[int(imageIndex)], -playerImagesDie[int(imageIndex)].width * (windowWidth / 900) * 0.07, playerImagesDie[int(imageIndex)].height * (windowHeight / 600) * 0.04, playerImagesDie[int(imageIndex)].width * (windowWidth / 900) * 0.25, playerImagesDie[int(imageIndex)].height * (windowHeight / 600) * 0.25);
    } 
    // If player is in Jumping state, loop through jump images once
    else if (isJumping) {
      if ( imageIndex > 5 ) {
        imageIndex = 5;
      }
      image(playerImagesJump[int(imageIndex)], 0, 0, playerImagesJump[int(imageIndex)].width * (windowWidth / 900) * 0.25, playerImagesJump[int(imageIndex)].height * (windowHeight / 600) * 0.25);
    } 
    // If player is in Celebrating state, loop though celebrating images
    else if (isCelebrating & !dead) {
      image(playerImagesCelebrate[int(imageIndex % playerImagesCelebrate.length)], -playerImagesCelebrate[int(imageIndex % playerImagesCelebrate.length)].width * (windowWidth / 900) * 0.02, -playerImagesCelebrate[int(imageIndex % playerImagesCelebrate.length)].height * (windowHeight / 600) * 0.025, playerImagesCelebrate[int(imageIndex % playerImagesCelebrate.length)].width * (windowWidth / 900) * 0.25, playerImagesCelebrate[int(imageIndex % playerImagesCelebrate.length)].height * (windowHeight / 600) * 0.25);
    } 
    // If player is staying still, loop though idle images
    else if (x == px) {
      image(playerImagesIdle[int(imageIndex % playerImagesIdle.length)], 0, 0, playerImagesIdle[int(imageIndex % playerImagesIdle.length)].width * (windowWidth / 900) * 0.25, playerImagesIdle[int(imageIndex % playerImagesIdle.length)].height * (windowHeight / 600) * 0.25);
    } 
    // If player is in Running state, loop though running images
    else if (isRunning) {
      image(playerImagesRun[int(imageIndex % playerImagesRun.length)], 0, 0, playerImagesRun[int(imageIndex % playerImagesRun.length)].width * (windowWidth / 900) * 0.25, playerImagesRun[int(imageIndex % playerImagesRun.length)].height * (windowHeight / 600) * 0.25);
    } 
    // Otherwise, player is in Walking state, loop through walking images
    else {
      image(playerImagesWalk[int(imageIndex % playerImagesWalk.length)], 0, 0, playerImagesWalk[int(imageIndex % playerImagesWalk.length)].width * (windowWidth / 900) * 0.25, playerImagesWalk[int(imageIndex % playerImagesWalk.length)].height * (windowHeight / 600) * 0.25);
    }
    // increment image index to change to the next image once per 4 frames
    imageIndex += 0.25;
    noTint();
    
    // Display parry effect
    pushMatrix();
    rotate(radians(-90));
    tint(c, parryAlpha);
    image(parry, 0, 0, 0.9 * h, 1.1 * w);
    noTint();
    popMatrix();
    
    // Display wound effect
    tint(255, 0, 0, cutAlpha);
    image(cut, 0, 0, 1.5 * w, 1.5 * h);
    noTint();
    
    popMatrix();
    
    // Decrement detail images to create fading out effect
    portalAlpha -= 10;
    cutAlpha -= 10;
    parryAlpha -= 10;
  }
  
  // Define move function
  void move() {
    // Save previous position values
    px = x;
    py = y;
    
    // Change position based on speed
    x += xSpeed;
    y += ySpeed;
    
    // Check if standing on a platform
    platformCheck();
    
    // If right move and running keys are activated, turn on Running state, accelerate speed and increase speed limit
    if ( right & !left & isRunning & !dead & !isCelebrating & !isAttacking & !isParrying ) {
      if ( !isRunning ) {
        imageIndex = 0;
        isRunning = true;
      }
      xSpeed += accel;
      if ( xSpeed > xSpeedMax * 3 ) {
        xSpeed = xSpeedMax * 3;
      }
    }
    // If left move and running keys are activated, turn on Running state, accelerate speed and increase speed limit
    else if ( left  & !right & isRunning & !dead & !isCelebrating & !isAttacking & !isParrying ) {
      if ( !isRunning ) {
        imageIndex = 0;
        isRunning = true;
      }
      xSpeed -= accel;
      if ( xSpeed < -xSpeedMax * 3 ) {
        xSpeed = -xSpeedMax * 3;
      }
    }
    // If right move key is activated, accelerate
    else if ( right & !left & !dead & !isCelebrating ) {
      xSpeed += accel;
      if ( xSpeed > xSpeedMax ) {
        xSpeed = xSpeedMax;
      }
    }
    // If left move key is activated, accelerate
    else if ( left  & !right & !dead & !isCelebrating ) {
      xSpeed -= accel;
      if ( xSpeed < -xSpeedMax ) {
        xSpeed = -xSpeedMax;
      }
    } 
    // If neither right or left pressed, decelerate
    else { 
      if ( xSpeed > 0 ) {
        xSpeed -= accel;
        if ( xSpeed < 0 ) {
          xSpeed = 0;
        }
      }
      else if ( xSpeed < 0 ) {
        xSpeed += accel;
        if ( xSpeed > 0 ) {
          xSpeed = 0;
        }
      }
      // If in Celebrating state, turn to another side periodically 
      if (isCelebrating) {
        //xSpeed = 0;
        if (imageIndex > maxImagesCelebrate * 2) {
          invert = !invert;
          imageIndex = 0;
        }
      }
    }
    
    // If Jumping key is activated, make a jump sound, accelerate speed upwards and enter the Jumping state
    if ( up & !isJumping & !dead & !isCelebrating ) {
      jumpSound.play();
      ySpeed = -23 * (windowHeight / 600);
      isJumping = true;
      imageIndex = 0;
    }
    
    // If in Jumping state, account for gravity force
    if ( isJumping ) {
      ySpeed += gravity;
    }
    
    // If moving right, turn on invert. Otherwise, turn it off 
    if (!isHit & x > px) invert = true;
    else if (!isHit & x < px) invert = false;
  }
  
  // Define method to check if player is standing on a platform
  void platformCheck() {
    // Loop through all the platform objects
    for (int i = 0; i < platforms.length; i++) {
      // Check for collision between platform upper bound and player's feet
      // If there is collision, stay on the platform, stop falling and exit the Jumping state
      if (x > platforms[i].leftBorder & x < platforms[i].rightBorder & y + playerImagesIdle[int(i % playerImagesIdle.length)].height * (windowHeight / 600) * 0.125 >= platforms[i].upBorder & py + playerImagesIdle[int(i % playerImagesIdle.length)].height * (windowHeight / 600) * 0.125 <= platforms[i].upBorder) {
        y = platforms[i].upBorder - playerImagesIdle[int(i % playerImagesIdle.length)].height * (windowHeight / 600) * 0.125;
        ySpeed = 0;
        isJumping = false;
        break;
      } 
      // Otherwise, enter the Jumping state
      else {
        isJumping = true;
      }
    }
  }
  
  // Define method to constrain players' movement
  void setEdges() {
    // If the game is started, constrain players' movement with the screen width
    if (start) {
      x = constrain(x, w * 0.5, width - w * 0.5);
    } 
    // Otherwise, constrain players' movement to the platforms they are standing on
    else {
      if (playerNumber == 1) {
        x = constrain(x, platforms[3].leftBorder + w * 0.2, platforms[3].rightBorder - w * 0.2);
      } else {
        x = constrain(x, platforms[2].leftBorder + w * 0.2, platforms[2].rightBorder - w * 0.2);
      }
    }
  }
  
  // Define fighting method 
  void fight(Player p) {
    // If the player is successfully attacked, display wound image, decrement health and score points, 
    // increment opponent's score and enter Hit state 
    if (!isHit & !dead & p.isAttacking & !isParrying & dist(p.x, p.y, x, y) < p.attackRange * 0.5 + playerRange * 0.5 & ((x < p.x & p.invert == false) | (x > p.x & p.invert == true)) ) {
      cutAlpha = 255;
      hp -= 1;
      score -= 5;
      p.score += 5;
      
      // If health drops to 0, enter Death state, set victory to true and set opponent's state to Celebrating
      if (hp == 0) {
        dead = true;
        victory = true;
        imageIndex = 0;
        p.isCelebrating = true;
        p.imageIndex = 0;
        p.xSpeed = 0;
      }  
      
      // Push player depending on from which side he was attacked and turn player to the other side
      if (!p.invert) {
        xSpeed -= 20 * (windowWidth / 900); 
        invert = true;
      } else if (p.invert) {
        xSpeed += 20 * (windowWidth / 900); 
        invert = false;
      }
      
      isHit = true;
      imageIndex = 0;
    } 
    // If the player is unsuccessfully attacked (parrying), display parry image, increment score
    // Set opponents state to Hit and push opponent back
    else if (!isHit & !dead & p.isAttacking & isParrying & dist(p.x, p.y, x, y) < p.attackRange * 0.5 + attackRange * 0.5 & ((x < p.x & p.invert == false) | (x > p.x & p.invert == true)) & ((x < p.x & invert == true) | (x > p.x & invert == false))) {
      parryAlpha = 255;
      score += 3;
      
      if (!invert) {
        p.xSpeed -= 20 * (windowWidth / 900);
        p.invert = true;
      } else if(invert) {
        p.xSpeed += 20 * (windowWidth / 900);
        p.invert = false; 
      }
      
      p.isAttacking = false;
      p.isHit = true;
      p.imageIndex = 0;
    }  
  }
  
  // Define method to display player's stats
  void displayStats() {
    // For Player 1
    if (playerNumber == 1) {
      fill(c);
      textFont(font);
      textSize(width / (windowWidth / 900) * 0.04);
      textAlign(RIGHT);
      
      // Display score
      text(score + "   Score", 0.99 * width, 0.05 * height);
      
      // If in Dead state, display dead face
      if ( dead ) {
        text("X_X   ", 0.99 * width, 0.1 * height);
      } 
      // If in Celebrating state, display happy face
      else if (isCelebrating) {
        text("O,O   ", 0.99 * width, 0.1 * height);
      } 
      // Otherwise, display lives
      else {
          for (int i = 0; i < hp; i++) {
          tint(c);
          image(life, 0.97 * width - i * 0.07 * height, 0.09 * height, 0.05 * height, 0.065 * height);
          noTint();
        }
      }
    } 
    // For Player 2
    else if (playerNumber == 2) {
      fill(c);
      textFont(font);
      textSize(width / (windowWidth / 900) * 0.04);
      textAlign(LEFT);
      
      // Display score
      text("Score   " + score, 0.01 * width, 0.05 * height);
      
      // If in Dead state, display dead face
      if ( dead ) {
        text("   X_X", 0.01 * width, 0.1 * height);
      } 
      // If in Celebrating state, display happy face
      else if (isCelebrating) {
        text("   O,O", 0.01 * width, 0.1 * height);
      } 
      // Otherwise, display lives
      else {
        for (int i = 0; i < hp; i++) {
          pushMatrix();
          scale(-1, 1);
          tint(c);
          image(life, -(0.03 * width + i * 0.07 * height), 0.09 * height, 0.05 * height, 0.065 * height);
          noTint();
          popMatrix();
        }
      }
    }
  }
}