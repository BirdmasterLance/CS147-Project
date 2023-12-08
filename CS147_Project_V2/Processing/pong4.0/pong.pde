// Serial Ports 
import processing.serial.*;
Serial port3; //game console  
Serial port1; //game controller 1
Serial port2; //game controller 2

//Background Images
PImage background_img;
PImage win_img;
int height = 700;
int width = 700;

//Game 1 Variables
boolean Game1_Loaded = false;
boolean Game2_Loaded = false;
boolean Game3_Loaded = false;
boolean gameOver = false;
int finalScore = 10;
boolean quit = false;

//Game Actors
// ------------------------------------------------------------------
Ball ball;
Ball balls[];
Player player1;
Player player2;

//Console Menu
// =========================================================================================================================================

//Handles the dimensions (700,700) of game window
void settings() {
  size(width, height);
}


void setup() {
  //NOTE: SERIAL PORT INDEXES CAN CHANGE
  print(Serial.list());
  port1 = new Serial(this, Serial.list()[2], 9600);
  port1.clear();
  port2 = new Serial(this, Serial.list()[1], 9600);
  port2.clear();
  port3 = new Serial(this, Serial.list()[0], 9600);
  port3.clear();
  
  //Load Images
  background_img = loadImage("COURT.jpg");
  background_img.resize(width, height);
  win_img = loadImage("WIN.jpeg");
  win_img.resize(width, height);  
  
  
  //Generate player 1
  player1 = new Player(50,height/2);
  player1.player_sprite = loadImage("player1.png");
  
  //Generate player 2
  player2 = new Player(width-150,height/2);
  player2.player_sprite = loadImage("player2.png");
}


int readButtonPressed() {
  //Determine if START was pressed, if so draw the game 
  int startButton = port3.read(); 
  if (startButton == 101) {
    Game1_setup();
    Game1_Loaded = true;
  }
  else if (startButton == 102) {
    Game2_setup();
    Game2_Loaded = true;
  }
  else if (startButton == 103) {
    Game3_setup();
    Game3_Loaded = true;
  }
  else if (startButton == 104) {
    port3.write(6);
    quit = true;
  }
  return startButton;
}


int checkGameOver() {
  int winner = 0;
  //Check if Player 1 won
  if(player1.score >= finalScore) {
    gameOver = true;
    winner = 1;
  }
  //Check if Player 2 won
  if(player2.score >= finalScore) {
    gameOver = true;
    winner = 2;
  }
  //No Win
  return winner;
}

void draw() {  
  if (quit == true) {
    //port3.write(6);
    //Draw Menu Screen
    background(0);
    fill(255, 255, 255);
    
    textAlign(CENTER, BOTTOM);
    textSize(100);
    text("L&L Gaming\nConsole\n", height/2, width/2);
    
    textAlign(CENTER);
    textSize(75);
    text("Created By:                 \n", height/2, width/2);
    
    textAlign(CENTER, TOP);
    textSize(50);
    text("\nAkyra Lee\nHuu Le    \n", height/2, width/2);
  }
  else {
    int buttonVal = readButtonPressed();
    int winner = checkGameOver();
    
    if (gameOver == true) {
      background(win_img);
      textAlign(CENTER);
      textSize(100);
      fill(0, 408, 612, 816);
      if (winner == 1) {
        text("PLAYER 1 WINS", height/2, width/2);
      }
      else if (winner == 2) {
        text("PLAYER 2 WINS", height/2, width/2);
      }
      Game1_Loaded = false;
      Game2_Loaded = false;
      Game3_Loaded = false;
    }
    else if (Game1_Loaded == true) {
      Game1_draw();
    }
    else if (Game2_Loaded == true) {
      Game2_draw();
    }
    else if (Game3_Loaded == true) {
      Game3_draw();
    }
    else {    
      //Draw Menu Screen
      background(0);
      fill(255, 255, 255);
      
      textAlign(CENTER, BOTTOM);
      textSize(100);
      text("L&L Gaming\nConsole\n", height/2, width/2);
      
      textAlign(CENTER);
      textSize(75);
      text("Menu:                       \n", height/2, width/2);
      
      textAlign(CENTER, TOP);
      textSize(50);
      text("\nButton 1 - EASY          \nButton 2 - NORMAL  \nButton 3 - EXTREME \n Button 4 - QUIT           ", height/2, width/2);
    }
  }
}


void keyPressed() {
  port3.write(key);
}



// Game Modules
// =========================================================================================================================================

//Pong Ball Class
// ------------------------------------------------------------------
class Ball {
  float ballX, ballY;
  float ballSize = 50;
  int ballColor = color(0);
  float ballDirX = 1, ballDirY = 1;
  float ballSpeedX = 1, ballSpeedY = 0;
  PImage ball_sprite;
  
  Ball (float bx, float by) {
    ballX = bx;
    ballY = by;
  }
  
  void drawBall() {
     image(ball_sprite, ballX+(ballSize)/2, ballY+(ballSize)/2, ballSize, ballSize);
  }
}


//Pong Player Class
// ------------------------------------------------------------------
class Player {  
  float racketX, racketY;
  color racketColor = color(0);
  float racketWidth = 100;
  float racketHeight = 100;
  PImage player_sprite;
  int score = 0;
  Player (float x, float y) {
    racketX = x;
    racketY = y;
  }
  void drawPlayer() {
    image(player_sprite, racketX, racketY, racketWidth, racketHeight);
  }
}


//Game Actors
// ------------------------------------------------------------------
void bounceOffBarrier(Ball B) {
 // Ball hits ceiling
 if(B.ballY+(B.ballSize/2) > height) {
   B.ballDirY = -1;
 }
 // Ball hits floor
 else if(B.ballY-(B.ballSize/2) < 0) {
   B.ballDirY = 1; 
 }
 
 int[] directions = {-1, 1};
 
 if(B.ballX+(B.ballSize/2) > width) {
   player1.score += 1;
   B.ballX = width/2;
   B.ballY = height/2;
   B.ballDirX = directions[int(random(directions.length))];
   B.ballDirY = directions[int(random(directions.length))];
   port3.write(1); //increment player 1 score
 }
 else if(B.ballX-(B.ballSize/2) < 0) {
   player2.score += 1;
   B.ballX = width/2;
   B.ballY = height/2;
   B.ballDirX = directions[int(random(directions.length))];
   B.ballDirY = directions[int(random(directions.length))];
   port3.write(2); //increment player 2 score
 }
}


void bounceOffRacket(Ball B) {
  if(B.ballX < player1.racketX + player1.racketWidth && B.ballX + (B.ballSize/2) + (B.ballSize/2) > player1.racketX && B.ballY < player1.racketY + player1.racketHeight && B.ballY + (B.ballSize/2) > player1.racketY) {
      B.ballDirX *= -1;
      B.ballX = player1.racketX + player1.racketWidth;
      //play hit sound
      port3.write(3);
  } 
  if((B.ballX < player2.racketX + player2.racketWidth) && (B.ballX + (B.ballSize/2) > player2.racketX) && B.ballY < player2.racketY + player1.racketHeight && B.ballY + (B.ballSize/2) > player2.racketY) {
      B.ballDirX *= -1;
      B.ballX = player2.racketX - (B.ballSize/2);
      //play hit sound
      port3.write(4);
  }
}




// Game 1 - Easy Pong
// =========================================================================================================================================

void Game1_setup() {

  //Generate ball
  ball = new Ball(width/4,height/5);
  ball.ball_sprite = loadImage("ball.png");
  
  player1.score = 0;
  player2.score = 0;
  gameOver = false;

  port3.write(5);
}


void Game1_draw() {
  float max_potentiometer_val = 256;
  float factor = height/max_potentiometer_val;
  
  //read input position values from controller 1
  if (port1.available() > 0) {
    float new_pos1 = port1.read();
    player1.racketY = 700 - new_pos1*factor;
  }
  //read input position values from controller 1
  if (port2.available() > 0) {
    float new_pos2 = port2.read();
    player2.racketY = 700 - new_pos2*factor;
  }
  
  //draw all game components
  background(background_img);
  ball.drawBall();
  player1.drawPlayer();
  player2.drawPlayer();
  
  if(player1.racketY < 0) player1.racketY = 0;
  if(player1.racketY + player1.racketHeight > height) player1.racketY = (int) (height-player1.racketHeight);
  
  if(player2.racketY < 0) player2.racketY = 0;
  if(player2.racketY + player2.racketHeight > height) player2.racketY = (int) (height-player2.racketHeight);
  
  ball.ballY += 6*ball.ballDirY;
  ball.ballX += 6*ball.ballDirX;
  bounceOffBarrier(ball);
  bounceOffRacket(ball);
}




// Game 2 - Normal Pong
// =========================================================================================================================================

void Game2_setup() {
  int num_balls = 2;

  //Generate balls
  balls = new Ball[num_balls];
  for (int index = 0; index < num_balls; index++) {
    balls[index] = new Ball(width/4,height/5);
    balls[index].ball_sprite = loadImage("ball.png");
  }
 
  player1.score = 0;
  player2.score = 0;
  gameOver = false;

  port3.write(5);
}


void Game2_draw() {  
  float max_potentiometer_val = 256;
  float factor = height/max_potentiometer_val;
  
  //read input position values from controller 1
  if (port1.available() > 0) {
    float new_pos1 = port1.read();
    player1.racketY = 700 - new_pos1*factor;
  }
  //read input position values from controller 1
  if (port2.available() > 0) {
    float new_pos2 = port2.read();
    player2.racketY = 700 - new_pos2*factor;
  }
   
  //draw all game components
  background(background_img);
  for (Ball b : balls) {
    b.drawBall();
    b.ballY += 6*b.ballDirY;
    b.ballX += 6*b.ballDirX;
    bounceOffBarrier(b);
    bounceOffRacket(b);
  }
 
  player1.drawPlayer();
  player2.drawPlayer();
  
  if(player1.racketY < 0) player1.racketY = 0;
  if(player1.racketY + player1.racketHeight > height) player1.racketY = (int) (height-player1.racketHeight);
  
  if(player2.racketY < 0) player2.racketY = 0;
  if(player2.racketY + player2.racketHeight > height) player2.racketY = (int) (height-player2.racketHeight);
}




// Game 3 - Extreme Pong
// =========================================================================================================================================

void Game3_setup() {
  
  int num_balls = 5;

  //Generate balls
  balls = new Ball[num_balls];
  for (int index = 0; index < num_balls; index++) {
    balls[index] = new Ball(width/4,height/5);
    balls[index].ball_sprite = loadImage("ball.png");
  }

  player1.score = 0;
  player2.score = 0;
  gameOver = false;

  port3.write(5);
}


void Game3_draw() {  
  float max_potentiometer_val = 256;
  float factor = height/max_potentiometer_val;
  
  //read input position values from controller 1
  if (port1.available() > 0) {
    float new_pos1 = port1.read();
    player1.racketY = 700 - new_pos1*factor;
  }
  //read input position values from controller 1
  if (port2.available() > 0) {
    float new_pos2 = port2.read();
    player2.racketY = 700 - new_pos2*factor;
  }
   
  //draw all game components
  background(background_img);
  for (Ball b : balls) {
    b.drawBall();
    b.ballY += 6*b.ballDirY;
    b.ballX += 6*b.ballDirX;
    bounceOffBarrier(b);
    bounceOffRacket(b);
  }
 
  player1.drawPlayer();
  player2.drawPlayer();
  
  if(player1.racketY < 0) player1.racketY = 0;
  if(player1.racketY + player1.racketHeight > height) player1.racketY = (int) (height-player1.racketHeight);
  
  if(player2.racketY < 0) player2.racketY = 0;
  if(player2.racketY + player2.racketHeight > height) player2.racketY = (int) (height-player2.racketHeight);
}
