// 0: Title Screen
// 1: Game Screen
// 2: Game-over Screen

int gameScreen = 0;

// Ball Variables
int ballX, ballY;
int ballSize = 20;
int ballColor = color(0);

// Racket Variables
color racketColor = color(0);
int racketX1, racketY1;
int racketX2, racketY2;
float racketWidth = 10;
float racketHeight = 100;

// Physics
float ballDirX = 1, ballDirY = 1;
float ballSpeedX = 1, ballSpeedY = 0;

void setup() {
  size(500,500);
  
  ballX=width/4;
  ballY=height/5;
  
  racketX1 = 50;
  racketY1 = height/2;
  
  racketX2 = width-50;
  racketY2 = height/2;
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
  background(255);
  drawBall();
  drawRacket1();
  drawRacket2();
  
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
 ellipse(ballX, ballY, ballSize, ballSize);
}

void drawRacket1() {
 fill(racketColor); 
 rect(racketX1, racketY1, racketWidth, racketHeight);
}

void drawRacket2() {
  fill(racketColor); 
  rect(racketX2, racketY2, racketWidth, racketHeight);
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
 if((ballY+(ballSize/2) > racketY1-(racketHeight/2) && (ballY-(ballSize/2)) < racketY1+(racketHeight/2))) {
   if (dist(ballX, ballY, ballX, racketX1)<=(ballSize/2)) {
       ballDirX *= -1;
       ballDirY *= -1;
   }
 }
 
 if((ballY+(ballSize/2) > racketY2-(racketHeight/2) && (ballY-(ballSize/2)) < racketY2+(racketHeight/2))) {
   if (dist(ballX, ballY, ballX, racketX2)<=(ballSize/2)) {
       ballDirX *= -1;
       ballDirY *= -1;
   }
 }
}
