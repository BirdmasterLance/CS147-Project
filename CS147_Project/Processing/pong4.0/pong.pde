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
boolean gameOver = false;
int player1Score = 0;
int player2Score = 0;
int finalScore = 10;



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
}


void draw() {
  //Determine if START was pressed, if so draw the game 
  int startButton = port3.read(); 
  if (startButton == 100) {
    Game1_setup();
    Game1_Loaded = true;
  }
  if (Game1_Loaded == true) {
    Game1_draw();
  }
  else {    
    //Draw Menu Screen
    background(0);
    textAlign(CENTER);
    textSize(50);
    fill(0, 408, 612, 816);
    text("PRESS PLAY BUTTON", height/2, width/2);
  }
  
  //Check if Player 1 won
  if(player1Score >= finalScore) {
    gameOver = true;
    background(win_img);
    textAlign(CENTER);
    textSize(100);
    fill(0, 408, 612, 816);
    text("PLAYER 1 WINS", height/2, width/2);
    player1Score = 0;
    if (startButton == 100) {
      Game1_Loaded = false;
    }
  }
  //Check if Player 2 won
  if(player2Score >= finalScore) {
    gameOver = true;
    background(win_img);
    textAlign(CENTER);
    textSize(100);
    fill(0, 408, 612, 816);
    text("PLAYER 2 WINS", height/2, width/2);
    player2Score = 0;
    if (startButton == 100) {
      Game1_Loaded = false;
    }
  }
}


//void keyPressed() {
//  port3.write(key);
//}




// Game 1 - Extreme Pong
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
Ball ball;
Player player1;
Player player2;


void Game1_setup() {

  //Generate ball
  ball = new Ball(width/4,height/5);
  ball.ball_sprite = loadImage("ball.png");
  
  //Generate player 1
  player1 = new Player(50,height/2);
  player1.player_sprite = loadImage("player1.png");
  
  //Generate player 2
  player2 = new Player(width-150,height/2);
  player2.player_sprite = loadImage("player2.png");
  
  gameOver = false;
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
  bounceOffBarrier();
  bounceOffRacket();
}

// Physics
void bounceOffBarrier() {
 // Ball hits ceiling
 if(ball.ballY+(ball.ballSize/2) > height) {
   ball.ballDirY = -1;
 }
 // Ball hits floor
 else if(ball.ballY-(ball.ballSize/2) < 0) {
   ball.ballDirY = 1; 
 }
 
 int[] directions = {-1, 1};
 
 if(ball.ballX+(ball.ballSize/2) > width) {
   player1.score += 1;
   ball.ballX = width/2;
   ball.ballY = height/2;
   ball.ballDirX = directions[int(random(directions.length))];
   ball.ballDirY = directions[int(random(directions.length))];
   port3.write(1); //increment player 1 score
 }
 else if(ball.ballX-(ball.ballSize/2) < 0) {
   player2.score += 1;
   ball.ballX = width/2;
   ball.ballY = height/2;
   ball.ballDirX = directions[int(random(directions.length))];
   ball.ballDirY = directions[int(random(directions.length))];
   port3.write(2); //increment player 2 score
 }
}


void bounceOffRacket() {
  if(ball.ballX < player1.racketX + player1.racketWidth && ball.ballX + (ball.ballSize/2) + (ball.ballSize/2) > player1.racketX && ball.ballY < player1.racketY + player1.racketHeight && ball.ballY + (ball.ballSize/2) > player1.racketY) {
      ball.ballDirX *= -1;
      ball.ballX = player1.racketX + player1.racketWidth;
      //play hit sound
      port3.write(3);
  } 
  if((ball.ballX < player2.racketX + player2.racketWidth) && (ball.ballX + (ball.ballSize/2) > player2.racketX) && ball.ballY < player2.racketY + player1.racketHeight && ball.ballY + (ball.ballSize/2) > player2.racketY) {
      ball.ballDirX *= -1;
      ball.ballX = player2.racketX - (ball.ballSize/2);
      //play hit sound
      port3.write(3);
  }
}
