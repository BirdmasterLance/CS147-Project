// 0: Title Screen
// 1: Game Screen
// 2: Game-over Screen


import processing.serial.*;

Serial port1;
Serial port2;

PImage player1_sprite;
PImage player2_sprite;
PImage ball_sprite;


int gameScreen = 0;

// Ball Variables
float ballX, ballY;
float ballSize = 50;
int ballColor = color(0);

// Racket Variables
color racketColor = color(0);
float racketX1, racketY1;
float racketX2, racketY2;
float racketWidth = 100;
float racketHeight = 100;

// Physics
float ballDirX = 1, ballDirY = 1;
float ballSpeedX = 1, ballSpeedY = 0;

void setup() {
  size(700,700);
  
  ballX=width/4;
  ballY=height/5;
  
  racketX1 = 50;
  racketY1 = height/2;
  
  racketX2 = width-150;
  racketY2 = height/2;
  
  player1_sprite = loadImage("pong_player1.png");
  player2_sprite = loadImage("pong_player2.png");
  ball_sprite = loadImage("ball.png");

  
  port1 = new Serial(this, Serial.list()[0], 9600);
  port1.clear();
  
  port2 = new Serial(this, Serial.list()[1], 9600);
  port2.clear();

}

void draw() {
 // Display the contents of the current screen
  if (gameScreen == 0) {
    initScreen();
  } else if (gameScreen == 1) {
    gameScreen();
  } else if (gameScreen == 2) {
    gameOverScreen();
  } 
}

// Screens
void initScreen() {
  background(0);
  textAlign(CENTER);
  text("Click To Start", height/2, width/2);
}

void gameScreen() {
  float max_potentiometer_val = 256;
  float factor = height/max_potentiometer_val;
  
  if (port1.available() > 0) {
     float new_pos1 = port1.read();
     racketY1 = 700 - new_pos1*factor;
   }
   
  if (port2.available() > 0) {
     float new_pos2 = port2.read();
     racketY2 = 700 - new_pos2*factor;
   }
     
  background(255);
  drawBall();
  drawRacket1();
  drawRacket2();
  
  if(racketY1 < 0) racketY1 = 0;
  if(racketY1 + racketHeight > height) racketY1 = (int) (height-racketHeight);
  
  if(racketY2 < 0) racketY2 = 0;
  if(racketY2 + racketHeight > height) racketY2 = (int) (height-racketHeight);
  
  ballY += 6*ballDirY;
  ballX += 6*ballDirX;
  bounceOffBarrier();
  bounceOffRacket();
}

void gameOverScreen() {
  
}

// Inputs
public void mousePressed() {
 if(gameScreen == 0) { 
   startGame();
 }
}

void keyPressed() {
  if(gameScreen == 1) {
    if(key == 'w') {
     racketY1 -= 35; 
    }
    if(key == 's') {
     racketY1 += 35; 
    }
    
    if(key == 'i') {
     racketY2 -= 35; 
    }
    if(key == 'k') {
     racketY2 += 35; 
    }
  }
}

void startGame() {
 gameScreen = 1; 
}

void drawBall() {
 fill(ballColor);
 //ellipse(ballX+(ballSize)/2, ballY+(ballSize)/2, ballSize, ballSize);
 image(ball_sprite, ballX+(ballSize)/2, ballY+(ballSize)/2, ballSize, ballSize);

}

void drawRacket1() {
 fill(racketColor); 
 //rect(racketX1, racketY1, racketWidth, racketHeight);
 image(player1_sprite, racketX1, racketY1, racketWidth, racketHeight);
 
}

void drawRacket2() {
  fill(racketColor); 
  //rect(racketX2, racketY2, racketWidth, racketHeight);
  image(player2_sprite, racketX2, racketY2, racketWidth, racketHeight);

}

// Physics
void bounceOffBarrier() {
 // Ball hits ceiling
 if(ballY+(ballSize/2) > height) {
   ballDirY = -1;
 }
 // Ball hits floor
 else if(ballY-(ballSize/2) < 0) {
   ballDirY = 1; 
 }
 
 if(ballX+(ballSize/2) > width) {
   ballDirX = -1;
 }
 else if(ballX-(ballSize/2) < 0) {
   ballDirX = 1;
 }
}

void bounceOffRacket() {
  if(ballX < racketX1 + racketWidth && ballX + (ballSize/2) + (ballSize/2) > racketX1 && ballY < racketY1 + racketHeight && ballY + (ballSize/2) > racketY1) {
      ballDirX *= -1;
      ballX = racketX1 + racketWidth;
  }
  
  //if(ballX < racketX1 + racketWidth && ballX > racketX1 && ballY < racketY1 + racketHeight && ballY > racketY1) {
  //    ballDirX *= -1;
  //    ballX = racketX1 + racketWidth;
  //}
  
  if((ballX < racketX2 + racketWidth) && (ballX + (ballSize/2) > racketX2) && ballY < racketY2 + racketHeight && ballY + (ballSize/2) > racketY2) {
      ballDirX *= -1;
      ballX = racketX2 - (ballSize/2);
  }
}
