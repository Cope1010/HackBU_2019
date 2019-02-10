
import java.util.*;

int startTime;
int passedTime;
int maxTime = 60000 * 4;

float projectProgress = 0;
boolean showHunger = false;
float hungerStatus = 100;
boolean showThirst = false;
float thirstStatus = 100;
boolean showFatigue = false;
float fatigueStatus = 100;
boolean showExercise = false;
float exerciseStatus = 100;
boolean hungerTutorialDisplayed = false;
boolean thirstTutorialDisplayed = false;
boolean fatigueTutorialDisplayed = false;
boolean exerciseTutorialDisplayed = false;

boolean fatigueEventTutorialDisplayed = false;
boolean exerciseEventTutorialDisplayed = false;
boolean forcedStopScreen = false;

String console = "";
ArrayList<String> consoleText;
int currentLine = 0;
float totalCharCount = 0;
float currentCharCount = 0;

ArrayList<PVector> foodLoc = new ArrayList<PVector>();
ArrayList<PVector> foodVel = new ArrayList<PVector>();
ArrayList<Float> foodRot = new ArrayList<Float>();
ArrayList<Float> foodNoi = new ArrayList<Float>();
ArrayList<Boolean> foodGood = new ArrayList<Boolean>();
float burgerY = -500;
float burgerdV = 0;
float burgerHealth = 20;
boolean hungerSceneDone = false;

ArrayList<PVector> waterLoc = new ArrayList<PVector>();
ArrayList<Integer> waterRot = new ArrayList<Integer>();
ArrayList<Integer> waterShape = new ArrayList<Integer>();
ArrayList<Boolean> waterOn = new ArrayList<Boolean>();
Queue<Integer> waterQueue = new LinkedList<Integer>();
int waterStream1 = 0;
int waterStream2 = 0;
int pool = 720;
boolean waterSceneDone = false;

ArrayList<PVector> sleepLoc = new ArrayList<PVector>();
ArrayList<Float> sleepSpeed = new ArrayList<Float>();
ArrayList<Float> sleepRot = new ArrayList<Float>();
float fadeOut1 = 0;
float fadeOut2 = 200;
float fadeOut3 = 100;

int walkingW = 70;
int walkingH = 200;
int walkingX = 605;
int walkingY = 509;
boolean walkingLeft = false;
boolean walkingRight = false;
ArrayList<Integer> pedX = new ArrayList<Integer>();
ArrayList<Integer> pedY = new ArrayList<Integer>();
ArrayList<Float> pedN = new ArrayList<Float>();
ArrayList<Integer> pedC1 = new ArrayList<Integer>();
ArrayList<Integer> pedC2 = new ArrayList<Integer>();
ArrayList<Integer> pedC3 = new ArrayList<Integer>();
int iFrames = 0;
int blackOut = 255;
PVector mouseLoc = new PVector(640, 390);

// 0 = console
// 1 = eating
// 2 = water
// 3 = sleep
// 4 = walking
int state = 0;
String message = "";
String subtitle = "";
int oFramesMax = 180;
int oFramesLeft = oFramesMax;

public void setup() {
  size(1280, 720);
  frameRate(60);
  
  startTime = millis();
  //startTime = millis() - 25000;
  consoleText = new ArrayList<String>();
  consoleText.add("class HackBU_2019 {");
  consoleText.add("    public static void main(String args[]) {");
  consoleText.add("        System.out.println(\"Hello World!\");");
  consoleText.add("        System.out.println(\"jk... I will quicksort this array instead!\");");
  consoleText.add("        int arr[] = {3, 8, 5, 1, 9};");
  consoleText.add("        int n = arr.length();");
  consoleText.add("        ");
  consoleText.add("        QuickSort qs = new QuickSort();");
  consoleText.add("        qs.sort(arr, 0, n-1);");
  consoleText.add("        ");
  consoleText.add("        System.out.println(\"Sorted Array: \");");
  consoleText.add("        printArray(arr);");
  consoleText.add("    }");
  consoleText.add("}");
  for (String s: consoleText) {
    totalCharCount += s.trim().length(); 
  }
  
  message = "HackBU 2019";
  subtitle = "Just type the code :)";
  
  drawLayout();
}

public void draw() {
  background(255);
  if (state == 0) drawConsole();
  if (state == 1) drawFood();
  if (state == 2) drawWater();
  if (state == 3) drawSleep();
  if (state == 4) drawWalking();
  //if (state == 0) drawActionButtons();
  drawLayout();
  drawTimer();
  drawStatusBars();
  checkStatusBarVisibilities();
  drawHungerEvent();
  drawFatigueEvent();
  drawThirstEvent();
  drawExerciseEvent();
  if (message != "") drawMessage();
}

void keyPressed() {
  if (thirstStatus <= 0) {
    if (waterSceneDone && key == 'd') {
      pool += random(20, 60);
      if (pool >= 720) {
        thirstStatus = random(25, 75);
        waterSceneDone = false;
        waterStream1 = 0;
        waterStream2 = 0;
        pool = 720;
      }
      hungerStatus -= .25;
      fatigueStatus -= .75;
      exerciseStatus -= .5;
      startTime -= 1500;
      return;
    }
  }
  if (key==ENTER||key==RETURN) {
    if (state == 0) {
      if (currentLine < consoleText.size() && console.equals(consoleText.get(currentLine))) {
        do {
          currentLine += 1;
        } while (currentLine < consoleText.size() && consoleText.get(currentLine).trim().length() == 0);
        console = "";
        int p = 0;
        while (currentLine < consoleText.size() && consoleText.get(currentLine).length() > p+4 && consoleText.get(currentLine).substring(p, (p+4)).equals("    ")) {
          p += 4;
          console += "    ";
        }
      }
    }
  } else if (key < 200) {
    if (state == 0) {
      char c;
      if (console.length() < consoleText.get(currentLine).length()) 
      {
        do {
          c = consoleText.get(currentLine).charAt(console.length());
          if (c == ' ') { console += " "; currentCharCount++; }
        } while (c == ' ');
        if (key == c) {
          console = console + key;
          currentCharCount++;
          projectProgress = 100.0 * (currentCharCount / totalCharCount) ;
        }
      }
    }
    
    if (state == 4) {
      if (key == 'a' || key == LEFT) {
        walkingLeft = true;
      } else if (key == 'd' || key == RIGHT) {
        walkingRight = true;
      }
    }
  }
}

void keyReleased() {
  if (state == 4) {
    if (key == 'a' || key == LEFT) {
      walkingLeft = false;
    } else if (key == 'd' || key == RIGHT) {
      walkingRight = false;
    }
  }
}

void mousePressed() {
  // walking button
  if (waterSceneDone) { return; }
  if (hungerStatus <= 0) {
    if (hungerSceneDone && mouseX > 300 && mouseX < 980 && mouseY > 150 && mouseY < 575) {
      if (burgerHealth <= 0) {
        hungerStatus = random(25, 75);
        hungerSceneDone = false;
        burgerHealth = 20;
        burgerY = -500;
        burgerdV = 0;
        fadeOut1 = 0;
        thirstStatus -= .75;
        fatigueStatus -= .5;
        exerciseStatus -= .25;
        startTime -= 1500;
        return;
      }
      burgerHealth = constrain(burgerHealth - random(.5, 1.5), 0, 20);
    }
  }
  if (state == 0) {
    if (showHunger && mouseX > 10 && mouseX < 300 && mouseY > 30 && mouseY < 50) {
      state = 1;
      for (int i = 0; i < 5; i++) {
        foodLoc.add(new PVector((int)random(100, 1180), (int)random(-1000, -500)));
        foodVel.add(new PVector(0, random(0, 2)));
        foodRot.add(random(0, 360));
        foodNoi.add(random(0, 10000));
        foodGood.add(random(0, 10)<7); 
      }
    }
    if (showThirst && mouseX > 300 && mouseX < 590 && mouseY > 30 && mouseY < 50) {
      state = 2;
      String p1 = "221122121212233211312111211222212322213132132121221232212131221122";
      for (int y = 0; y < 6; y++) {
        for (int x = 0; x < 11; x++) {
          waterLoc.add(new PVector(90 + (100*x), 85 + (100*y)));
          waterRot.add(((int)random(0, 4))*90);
          waterShape.add(Character.getNumericValue(p1.charAt((y*11)+x)));
          waterOn.add(false);
        }
      }
      updateWater();
    }
    if (showFatigue && mouseX > 590 && mouseX < 880 && mouseY > 30 && mouseY < 50) {
      state = 3;
      for (int i = 0; i < 4; i++) {
        int rand = (int)random(0, 4);
        PVector s;
        if (rand == 0) s = new PVector(random(0, 1280), random(-1000, -500));
        else if (rand == 1) s = new PVector(random(-1000, -500), random(0, 720));
        else if (rand == 2) s = new PVector(random(0, 1280), random(1220, 1720));
        else s = new PVector(random(1780, 2280), random(0, 720));
        sleepLoc.add(s);
        sleepSpeed.add(random(2, 4));
        sleepRot.add(0.0);
      }
    }
    if (showExercise && mouseX > 880 && mouseX < 1170 && mouseY > 30 && mouseY < 50) {
      state = 4;
      for (int i = 0; i < 15; i++) {
        pedX.add((int)random(400, 880));
        pedY.add((int)random(-700, -100));
        pedN.add(random(0, 10000));
        pedC1.add((int)random(0, 255));
        pedC2.add((int)random(0, 255));
        pedC3.add((int)random(0, 255));
      }
    }
  } else if (state == 1) {
    for (int i = 0; i < foodLoc.size(); i++) {
      if (mouseX > foodLoc.get(i).x && mouseX < foodLoc.get(i).x + 100 && mouseY > foodLoc.get(i).y && mouseY < foodLoc.get(i).y + 100) {
        if (foodGood.get(i)) {
          hungerStatus += 10;
          thirstStatus -= 1;
          fatigueStatus -= .5;
          exerciseStatus -= .25;
        } else {
          hungerStatus -= 10;
          thirstStatus -= 3;
          fatigueStatus -= 2;
          exerciseStatus -= 1;
        }
        if (hungerStatus > 100) {
          foodLoc.clear();
          foodVel.clear();
          foodNoi.clear();
          foodRot.clear();
          foodGood.clear();
          hungerStatus = 100;
          state = 0;
          return;
        }
        foodLoc.set(i, new PVector((int)random(100, 1180), (int)random(-1000, -100)));
        foodVel.set(i, new PVector(0, random(0, 2)));
        foodRot.set(i, random(0, 360));
        foodNoi.set(i, random(0, 10000));
        foodGood.set(i, random(0, 10)<8);
        break;
      }
    }
  } else if (state == 2) {
    for (int i = 0; i < 66; i++) {
      if (mouseX > waterLoc.get(i).x && mouseX < waterLoc.get(i).x + 100 && mouseY > waterLoc.get(i).y && mouseY < waterLoc.get(i).y + 100) {
        int deg = waterRot.get(i) + 90;
        if (deg == 360) deg = 0;
        waterRot.set(i, deg); 
        updateWater();
      }
    }
  }
}

public void drawFood() {
  if (!hungerTutorialDisplayed) {
    message = "Apple A Day";
    subtitle = "Use your mouse to click the green apples!";
    hungerTutorialDisplayed = true;
  }
  
   for (int i = 0; i < foodLoc.size(); i ++) {
     noStroke();
     pushMatrix();
     translate(foodLoc.get(i).x+50, foodLoc.get(i).y+50);
     rotate(foodRot.get(i));
     fill(0, 0, 0, 100);
     rect(-40, -40, 100, 100, 16, 16, 16, 16);
     if (foodGood.get(i)) fill(#1FDB36);
     else fill(#EA342B);
     rect(-50, -50, 100, 100, 16, 16, 16, 16);
     popMatrix();
     foodLoc.set(i, foodLoc.get(i).add(foodVel.get(i)));
     foodVel.set(i, foodVel.get(i).add(new PVector(0, .06)));
     foodRot.set(i, foodRot.get(i) + map(noise(foodNoi.get(i)), 0, 1, -.1, .1));
     foodNoi.set(i, foodNoi.get(i) + .001);
     if (foodLoc.get(i).y > 1000) {
       foodLoc.set(i, new PVector((int)random(100, 1180), (int)random(-1000, -100)));
       foodVel.set(i, new PVector(0, random(0, 2)));
       foodRot.set(i, random(0, 360));
       foodNoi.set(i, random(0, 10000));
       foodGood.set(i, random(0, 10)<7);  
     }
   }
   thirstStatus -= .03;
   fatigueStatus -= .02;
   exerciseStatus -= .01;
}

public void drawWater() {
  if (!thirstTutorialDisplayed) {
    message = "Thirsty";
    subtitle = "Click on the pipes to rotate them and reroute the water!";
    thirstTutorialDisplayed = true;
  }
  
  fill(#834409);
  rect(10, 60, 1260, 650);
  noStroke();
  fill(#6A3605);
  rect(90, 85, 1100, 600);
  fill(100);
  rect(10, 215, 80, 40);
  rect(1190, 515, 80, 40);
  fill(50);
  rect(1190, 520, 80, 30);
  fill(#0077be); // water color
  rect(10, 220, 80, 30);
  for (int i = 0; i < 66; i++) {
    int x = (int)waterLoc.get(i).x;
    int y = (int)waterLoc.get(i).y;
    float r = waterRot.get(i);
    int shape = waterShape.get(i);
    int innerColor;
    if (waterOn.get(i)) innerColor = color(#0077be);
    else innerColor = color(50);
    pushMatrix();
    translate(x+50, y+50);
    rotate(radians(waterRot.get(i)));
    if (shape == 1) {
      fill(100);
      rect(-50, -50+30, 100, 40);
      fill(innerColor);
      rect(-50, -50+35, 100, 30);
    } else if (shape == 2) {
      fill(100);
      rect(-50, -50+30, 70, 40);
      rect(-50+30, -50, 40, 70);
      fill(innerColor);
      rect(-50, -50+35, 65, 30);
      rect(-50+35, -50, 30, 65);
    } else if (shape == 3) {
      fill(100);
      rect(-50, -50+30, 70, 40);
      rect(-50+30, -50, 40, 100);
      fill(innerColor);
      rect(-50, -50+35, 65, 30);
      rect(-50+35, -50, 30, 100);
    }
    popMatrix();
  }
  hungerStatus -= .005;
  fatigueStatus -= .02;
  exerciseStatus -= .01;
  if ((waterRot.get(54) == 90 || waterRot.get(54) == 180) && waterOn.get(54)) {
    waterLoc.clear();
    waterRot.clear();
    waterShape.clear();
    waterOn.clear();
    thirstStatus = 100;
    state = 0;
  }
}

public void drawSleep() {
  if (!fatigueTutorialDisplayed) {
    message = "Nap Time";
    subtitle = "Use your mouse to move your shield\n and block the incoming hackers!";
    fatigueTutorialDisplayed = true;
  }
  
  fill(0);
  noStroke();
  rect(10, 60, 1260, 650); //<>//
  fill(245);
  rect(610, 345, 60, 90);
  fill(#4D69F0);
  rect(610, 370, 60, 65);
  fill(#EDD6A8);
  rect(632, 354, 16, 16);
  fill(#F0EA7B, 30);
  //(640, 390) center
  ellipse(640, 390, 400, 400);
  ellipse(640, 390, 200, 200);
  ellipse(640, 390, 100, 100);
  pushMatrix();
  noFill();
  stroke(255);
  strokeWeight(10);
  translate(640, 390);
  PVector up = new PVector(0, -1);
  PVector mouse = new PVector(mouseX-640, mouseY-390);
  float a = PVector.angleBetween(up, mouse);
  if (mouseX >= 640) rotate(a);
  else rotate(a = -a);
  arc(0, 0, 200, 200, -7*PI/10, -3*PI/10);
  popMatrix();
  
  for (int i = 0; i < sleepLoc.size(); i++) {
    pushMatrix();
    float mA = PVector.angleBetween(new PVector(0, -1), new PVector(sleepLoc.get(i).x-640, sleepLoc.get(i).y-390));
    translate(sleepLoc.get(i).x, sleepLoc.get(i).y);    
    if (sleepLoc.get(i).x >= 640) { sleepRot.set(i, mA); rotate(mA); }
    else { sleepRot.set(i, -mA); rotate(mA = -mA); }
    fill(#F72419);
    noStroke();
    rect(-15, -15, 30, 30);
    sleepLoc.set(i, sleepLoc.get(i).add(new PVector(640, 390).sub(sleepLoc.get(i)).normalize().mult(sleepSpeed.get(i))));
    if (dist(640, 390, sleepLoc.get(i).x, sleepLoc.get(i).y) <= 120 && dist(640, 390, sleepLoc.get(i).x, sleepLoc.get(i).y) >= 80 && ((mA > a - .8 && mA < a + .8) || (abs(mA) > 2.4 && abs(a) > 2.4))) {
      int rand = (int)random(0, 4);
      PVector s;
      if (rand == 0) s = new PVector(random(0, 1280), random(-300, 0));
      else if (rand == 1) s = new PVector(random(-300, 0), random(0, 720));
      else if (rand == 2) s = new PVector(random(0, 1280), random(750, 1050));
      else s = new PVector(random(1300, 1700), random(0, 720));
      sleepLoc.set(i, s);
      sleepSpeed.set(i, random(2, 4));
      sleepRot.set(i, 0.0);
    }
    if (iFrames == 0 && dist(640, 390, sleepLoc.get(i).x, sleepLoc.get(i).y) <= 5) {
      fatigueStatus -= 10;
      hungerStatus -= 2;
      thirstStatus -= 1;
      exerciseStatus -= 3;
      iFrames = 60;
    }
    if (dist(640, 390, sleepLoc.get(i).x, sleepLoc.get(i).y) <= 5) {
      int rand = (int)random(0, 4);
      PVector s;
      if (rand == 0) s = new PVector(random(0, 1280), random(-300, 0));
      else if (rand == 1) s = new PVector(random(-300, 0), random(0, 720));
      else if (rand == 2) s = new PVector(random(0, 1280), random(750, 1050));
      else s = new PVector(random(1300, 1700), random(0, 720));
      sleepLoc.set(i, s);
      sleepSpeed.set(i, random(2, 4));
      sleepRot.set(i, 0.0);
    }
    popMatrix();
  }
  
  if (iFrames > 0) iFrames--;
  fatigueStatus += .11;
  hungerStatus -= .02;
  thirstStatus -= .01;
  exerciseStatus -= .03;
  if (fatigueStatus >= 100) {
    sleepLoc.clear();
    sleepSpeed.clear();
    sleepRot.clear();
    fatigueStatus = 100;
    state = 0;
  }
}

public void drawWalking() {
  if (!exerciseTutorialDisplayed) {
    message = "Nature?";
    subtitle = "Use the 'a' and 'd' keys to move left and right\nand dodge the oncoming walkers!";
    exerciseTutorialDisplayed = true;
  }
  
  noStroke();  
  background(#40BF3A);
  fill(#AF9E7A);
  beginShape();
  vertex(100, 720);
  vertex(550,0);
  vertex(630,0);
  vertex(1080,720);
  endShape();
  
  for (int i = 0; i < pedX.size(); i++) {
    int x = pedX.get(i);
    int y = pedY.get(i);
    int w = (int)map(y, 60, 710, 35, 105);
    int h = (int)map(y, 60, 710, 100, 300);
    float n = pedN.get(i);
    color c = color(pedC1.get(i), pedC2.get(i), pedC3.get(i));
    fill(0, 0, 0, 75);
    rect(x+5, y+5, w, h);
    fill(c);
    rect(x, y, w, h);
    fill(#EDD6A8);
    rect(x, y, w, w);
    pedY.set(i, y + (int)constrain(map(y, 60, 710, 2, 10), 2, 10));
    pedX.set(i, x + (int)map(noise(n), 0, 1, -5, 5));
    pedN.set(i, n + .01);
    if (y > 1000) { 
      pedX.set(i, (int)random(400, 850));
      pedY.set(i, (int)random(-500, -100));
    }
    if (y > 450 && y < 570) {
      if (iFrames == 0 && (((walkingX+5) < x + w && (walkingX+walkingW-5) > x + w) || ((walkingX+walkingW-5) > x && (walkingX+5) < x + w))) {
        exerciseStatus -= 15;
        fatigueStatus -= 2;
        hungerStatus -= 3;
        thirstStatus -= 5;
        iFrames = 60;
      }
    }
  } 
  
  exerciseStatus += .11;
  hungerStatus -= .03;
  thirstStatus -= .02;
  fatigueStatus -= .01;
  if (iFrames > 0) iFrames--;
  if (exerciseStatus >= 100) {
    exerciseStatus = 100;
    pedX.clear();
    pedY.clear();
    pedN.clear();
    pedC1.clear();
    pedC2.clear();
    pedC3.clear();
    walkingLeft = false;
    walkingRight = false;
    state = 0;
    return;
  }
  
  fill(#F52720);
  rect(walkingX, walkingY, walkingW, walkingH);
  fill(#EDD6A8);
  rect(walkingX, walkingY, walkingW, walkingW);
  int speed = 7;
  if (walkingLeft && !walkingRight) walkingX = constrain(walkingX - speed, 200, 900);
  else if (walkingRight && !walkingLeft) walkingX = constrain(walkingX + speed, 200, 900);
}

public void drawConsole() {
  PFont mono;
  mono = createFont("Courier", 20);
  textAlign(LEFT);
  
  fill(#D1F6FA);
  noStroke();
  rect(12, 340, 1257, 30); 
  
  fill(140);
  int c = 0;
  for (int i = currentLine; i < consoleText.size(); i++) {
    String pr = "";
    String b = "";
    if (i == currentLine) {
      for (int j = 0; j < console.length(); j++) { pr += " "; b += " "; }
      pr += consoleText.get(i).substring(console.length());
    } else {
      pr = consoleText.get(i);
    }
    textFont(mono);
    text(pr, 30, 360 + ((c) * 30));
    c++;
  }
  fill(0);
  c = 1;
  for (int i = currentLine - 1; i >= 0; i--) {
    textFont(mono);
    text(consoleText.get(i), 30, 360 - ((c++) * 30));
  }
  text(console, 30, 360);
  
  hungerStatus -= .03;
  thirstStatus -= .03;
  fatigueStatus -= .03;
  exerciseStatus -= .03;
}

public void drawActionButtons() {
  if (showHunger) {
    fill(#F73E3E);
    stroke(100);
    strokeWeight(3);
    rect(1160, 70, 100, 30);
  }
  if (showThirst) {
    fill(#3E7AF7);
    stroke(100);
    strokeWeight(3);
    rect(1160, 110, 100, 30);
  }
  if (showFatigue) {
    fill(#2FD330);
    stroke(100);
    strokeWeight(3);
    rect(1160, 150, 100, 30);
  }
  if (showExercise) {
    fill(#C23EF7);
    stroke(100);
    strokeWeight(3);
    rect(1160, 190, 100, 30);
  }
}

public void checkStatusBarVisibilities() {
  if (passedTime > (maxTime / 16)) { if (!showHunger) { hungerStatus = 25; message = "Health"; subtitle += "Click on the new status bars\nto replenish them when they get low!"; } showHunger = true; }
  if (passedTime > (maxTime / 8)) { if (!showThirst)  thirstStatus = 25; showThirst = true; }
  if (passedTime > (maxTime / 8) * 2) { if (!showFatigue) fatigueStatus = 25; showFatigue = true; }
  if (passedTime > (maxTime / 8) * 3) { if (!showExercise) exerciseStatus = 25; showExercise = true; } 
}

public void drawStatusBars() {
  fill(#F4F560);
  float progressBar1 = constrain(projectProgress * 11.6, 0, 580);
  float progressBar2 = constrain((projectProgress - 50) * 11.6, 0, 580);
  rect(10, 10, progressBar1, 20);
  if (projectProgress > 50) rect(690, 10, progressBar2, 20); 

  textSize(15);
  fill(#F73E3E);
  if (showHunger) { rect(10, 30, constrain(hungerStatus * 2.9, 0, 290), 20); fill(0); text("Hunger", 150, 38); }
  fill(#3E7AF7);
  if (showThirst) { rect(300, 30, constrain(thirstStatus * 2.9, 0, 290), 20); fill(0); text("Thirst", 440, 38); }
  fill(#2FD330);
  if (showFatigue) { rect(690, 30, constrain(fatigueStatus * 2.9, 0, 290), 20); fill(0); text("Fatigue", 830, 38); }
  fill(#C23EF7);
  if (showExercise) { rect(980, 30, constrain(exerciseStatus * 2.9, 0, 290), 20); fill(0); text("Exercise", 1120, 38); }
}

public void drawTimer() {
  passedTime = millis() - startTime;
  int hour = constrain(passedTime / (maxTime / 24), 0, 24);
  int minute = constrain((passedTime % (maxTime / 24)) / ((maxTime / 24) / 60), 0, 59);
  String hours;
  if (hour < 10) hours = "0" + hour;
  else hours = hour + "";
  String minutes;
  if (minute < 10) minutes = "0" + minute;
  else minutes = minute + "";
  String timer = hours + ":" + minutes;
  textAlign(CENTER, CENTER);
  textSize(25);
  fill(0);
  if (hour >= 24) {
    message = "STOP";
    subtitle = "Time is up!\nYou completed " + projectProgress + "% of your project";
    if (projectProgress < 33) subtitle += "...";
    else if (projectProgress > 66) subtitle += "!";
    else if (projectProgress >= 100) subtitle += "!!!";
    else subtitle += ".";
    state = 0;
    timer = "24:00";
  }
  text(timer, 641, 26); 
}

public void drawLayout() {
  // layout 
  fill(0);
  noStroke();
  rect(0, 0, 10, 720);
  rect(1270, 0, 10, 720);
  rect(0, 0, 1280, 60);
  rect(0, 710, 1280, 10);
  
  fill(255, 255, 255, 0);
  strokeWeight(3);
  stroke(75);
  rect(10, 60, 1260, 650);
  
  fill(255, 255, 255);
  // progress bars background
  rect(10, 10, 580, 20);
  rect(690, 10, 580, 20);
  
  if (showHunger) rect(10, 30, 290, 20);
  if (showThirst) rect(300, 30, 290, 20);
  
  if (showFatigue) rect(690, 30, 290, 20);
  if (showExercise) rect(980, 30, 290, 20);
  
  //timer background
  rect(600, 10, 80, 40);
}

public void drawMessage() {
  startTime += 15;
  frameRate(60);
  if (oFramesLeft > 0) {
    fill(0, 200);
    rect(0, 0, width, height);
    textSize(100);
    textAlign(CENTER, CENTER);
    fill(255);
    stroke(0);
    strokeWeight(5);
    text(message, 640, 300);
    textSize(35);
    strokeWeight(3);
    text(subtitle, 640, 420);
    oFramesLeft--;
    if (message.equals("STOP")) {
      frameRate(0);
    }
  } else {
    oFramesLeft = oFramesMax;
    message = "";
    subtitle = "";
  }
}

public void drawHungerEvent() {
  if (hungerSceneDone) {
      fill(0, 0, 0, 255);
      rect(0, 0, width, height);
      fill(#F0E085);
      rect(340, burgerY, 600, 200, 200, 200, 0, 0);
      fill(#1BCB30);
      rect(300, burgerY+200, 680, 50, 20, 20, 20, 20);
      fill(#F7F134);
      rect(340, burgerY+250, 600, 25); 
      fill(#43340B);
      rect(320, burgerY+275, 640, 100, 10, 10, 10, 10);
      fill(#F0E085);
      rect(340, burgerY+375, 600, 100, 0, 0, 100, 100);
      fill(255);
      rect(440, 50, 400, 60);
      fill(255, 0, 0);
      rect(440, 50, map(burgerHealth, 0, 20, 0, 400), 60);
      return;
  }
  if (hungerStatus <= 0 && showHunger) {
    if (burgerY < 150) {
      fill(0, 0, 0, fadeOut1);
      rect(0, 0, width, height);
      fill(#F0E085);
      rect(340, burgerY, 600, 200, 200, 200, 0, 0);
      fill(#1BCB30);
      rect(300, burgerY+200, 680, 50, 20, 20, 20, 20);
      fill(#F7F134);
      rect(340, burgerY+250, 600, 25); 
      fill(#43340B);
      rect(320, burgerY+275, 640, 100, 10, 10, 10, 10);
      fill(#F0E085);
      rect(340, burgerY+375, 600, 100, 0, 0, 100, 100);
      burgerY += burgerdV;
      burgerdV += .1;
      fadeOut1 = constrain(fadeOut1 + 2, 0, 255);
    } else {
      hungerSceneDone = true;
      fill(0, 0, 0, 255);
      rect(0, 0, width, height);
      fill(#F0E085);
      rect(340, burgerY, 600, 200, 200, 200, 0, 0);
      fill(#1BCB30);
      rect(300, burgerY+200, 680, 50, 20, 20, 20, 20);
      fill(#F7F134);
      rect(340, burgerY+250, 600, 25); 
      fill(#43340B);
      rect(320, burgerY+275, 640, 100, 10, 10, 10, 10);
      fill(#F0E085);
      rect(340, burgerY+375, 600, 100, 0, 0, 100, 100);
      fill(255);
      rect(440, 50, 400, 60);
      fill(255, 0, 0);
      rect(440, 50, map(burgerHealth, 0, 20, 0, 400), 60);
      message = "Big Mac";
      subtitle = "Click the burger boss to widdle down his health!";
    }
  }
}

public void drawThirstEvent() {
  fill(#0077be, 200);
  if (waterSceneDone) {
    rect(0, pool, 1280, 720-pool);
    return;
  }
  if (thirstStatus <= 0 && showThirst) {
    if (waterStream1 < 720 && pool == 720) {
      rect(400, waterStream1-720, 30, 720);
      waterStream1 += 10;
    } else if (waterStream2 < 720 && pool == 720) {
      rect(700, waterStream2-720, 50, 720);
      rect(400, waterStream1-720, 30, 720);
      waterStream2 += 10;
    } else if (pool > 0) {
      rect(0, pool, 1280, 720-pool);
      rect(700, waterStream2-720, 50, 720);
      rect(400, waterStream1-720, 30, 720);
      //fill(0, 0, 0, fadeOut1);
      //rect(0, 0, 1280, 720);
      pool -= 4;
      waterStream1 -= 4;
      waterStream2 -= 4;
      //fadeOut1 += 1.41176471;
    } else {
      waterSceneDone = true; 
      rect(0, pool, 1280, 720-pool);
      message = "Flooded!";
      subtitle = "Spam 'd' to drink all the water!";
    }
  }
}

public void drawFatigueEvent() {
  if (fatigueStatus <= 0 && showFatigue) {
    if (fadeOut1 < 200) {
      fill(0, 0, 0, fadeOut1);
      rect(0, 0, width, height);
      fadeOut1 += 1;
    } else if (fadeOut2 > 100) {
      fill(0, 0, 0, fadeOut2);
      rect(0, 0, width, height);
      fadeOut2 -= 3;
    } else if (fadeOut3 < 255) {
      fill(0, 0, 0, fadeOut3);
      rect(0, 0, width, height);
      fadeOut3 += 1;
    } else {
      startTime -= random(20000, 60000);
      fatigueStatus = random(25, 75);
      hungerStatus -= 2;
      thirstStatus -= 1;
      exerciseStatus -= 5; 
      fadeOut1 = 0;
      fadeOut2 = 200;
      fadeOut3 = 100;
    }
  } 
}

public void drawExerciseEvent() {
  if (exerciseStatus <= 0 && showExercise) {
    if (!fatigueEventTutorialDisplayed) {
      message = "Lights Out";
      subtitle = "Quickly draw circles with your mouse to generate power.";
      fatigueEventTutorialDisplayed = true;
    }
    fill(0, 0, 0, blackOut);
    rect(0, 0, width, height);
    float mouseSpeed = abs((mouseLoc.sub(new PVector(mouseX, mouseY)).mag()));
    mouseLoc = new PVector(mouseX, mouseY);
    if (mouseSpeed > 100) {
      blackOut -= 2;
      startTime -= 230;
    }
    if (blackOut <= 0) {
      exerciseStatus = random(25, 75);
    }
  }
}

public void updateWater() {
  for (int i = 0; i < 66; i++) waterOn.set(i, false); 
  waterQueue.clear();
  if (waterRot.get(11) == 0 || waterRot.get(11) == 270) { waterQueue.add(11); }
  while (waterQueue.size() > 0) { updateWater(waterQueue.remove()); }
}

public void updateWater(int i) {
  if (i < 0 || i >= 66) return; 
  waterOn.set(i, true);
  if (waterShape.get(i) == 1) {
    // up
    if (waterRot.get(i) == 90 || waterRot.get(i) == 270) {
      if (i-11 >= 0 && !waterOn.get(i-11)) {
        if (waterShape.get(i-11) == 1) {
          if (waterRot.get(i-11) == 90 || waterRot.get(i-11) == 270) waterQueue.add(i-11);
        } else if (waterShape.get(i-11) == 2) {
          if (waterRot.get(i-11) == 180 || waterRot.get(i-11) == 270) waterQueue.add(i-11);
        } else if (waterShape.get(i-11) == 3) {
          if (waterRot.get(i-11) != 90) waterQueue.add(i-11);
        }
      } 
    }
    // left
    if (waterRot.get(i) == 0 || waterRot.get(i) == 180) {
      if (i%11 != 0 && !waterOn.get(i-1)) {
        if (waterShape.get(i-1) == 1) {
          if (waterRot.get(i-1) == 0 || waterRot.get(i-1) == 180) waterQueue.add(i-1);
        } else if (waterShape.get(i-1) == 2) {
          if (waterRot.get(i-1) == 90 || waterRot.get(i-1) == 180) waterQueue.add(i-1);
        } else if (waterShape.get(i-1) == 3) {
          if (waterRot.get(i-11) != 0) waterQueue.add(i-1);
        }
      }
    } 
    //down
    if (waterRot.get(i) == 90 || waterRot.get(i) == 270) {
      if (i+11 < 66 && !waterOn.get(i+11)) {
        if (waterShape.get(i+11) == 1) {
          if (waterRot.get(i+11) == 90 || waterRot.get(i+11) == 270) waterQueue.add(i+11);
        } else if (waterShape.get(i+11) == 2) {
          if (waterRot.get(i+11) == 0 || waterRot.get(i+11) == 90) waterQueue.add(i+11);
        } else if (waterShape.get(i+11) == 3) {
          if (waterRot.get(i+11) != 270) waterQueue.add(i+11);
        }
      } 
    }
    //right
    if (waterRot.get(i) == 0 || waterRot.get(i) == 180) {
      if ((i+1)%11 != 0 && !waterOn.get(i+1)) {
        if (waterShape.get(i+1) == 1) {
          if (waterRot.get(i+1) == 0 || waterRot.get(i+1) == 180) waterQueue.add(i+1);
        } else if (waterShape.get(i+1) == 2) {
          if (waterRot.get(i+1) == 0 || waterRot.get(i+1) == 270) waterQueue.add(i+1);
        } else if (waterShape.get(i+1) == 3) {
          if (waterRot.get(i+1) != 180) waterQueue.add(i+1);
        }
      } 
    }
  } else if (waterShape.get(i) == 2) {
    // up
    if (waterRot.get(i) == 90 || waterRot.get(i) == 0) {
      if (i-11 >= 0 && !waterOn.get(i-11)) {
        if (waterShape.get(i-11) == 1) {
          if (waterRot.get(i-11) == 90 || waterRot.get(i-11) == 270) waterQueue.add(i-11);
        } else if (waterShape.get(i-11) == 2) {
          if (waterRot.get(i-11) == 180 || waterRot.get(i-11) == 270) waterQueue.add(i-11);
        } else if (waterShape.get(i-11) == 3) {
          if (waterRot.get(i-11) != 90) waterQueue.add(i-11);
        }
      } 
    }
    // left
    if (waterRot.get(i) == 0 || waterRot.get(i) == 270) {
      if (i%11 != 0 && !waterOn.get(i-1)) {
        if (waterShape.get(i-1) == 1) {
          if (waterRot.get(i-1) == 0 || waterRot.get(i-1) == 180) waterQueue.add(i-1);
        } else if (waterShape.get(i-1) == 2) {
          if (waterRot.get(i-1) == 90 || waterRot.get(i-1) == 180) waterQueue.add(i-1);
        } else if (waterShape.get(i-1) == 3) {
          if (waterRot.get(i-11) != 0) waterQueue.add(i-1);
        }
      }
    } 
    //down
    if (waterRot.get(i) == 180 || waterRot.get(i) == 270) {
      if (i+11 < 66 && !waterOn.get(i+11)) {
        if (waterShape.get(i+11) == 1) {
          if (waterRot.get(i+11) == 90 || waterRot.get(i+11) == 270) waterQueue.add(i+11);
        } else if (waterShape.get(i+11) == 2) {
          if (waterRot.get(i+11) == 0 || waterRot.get(i+11) == 90) waterQueue.add(i+11);
        } else if (waterShape.get(i+11) == 3) {
          if (waterRot.get(i+11) != 270) waterQueue.add(i+11);
        }
      } 
    }
    //right
    if (waterRot.get(i) == 90 || waterRot.get(i) == 180) {
      if ((i+1)%11 != 0 && !waterOn.get(i+1)) {
        if (waterShape.get(i+1) == 1) {
          if (waterRot.get(i+1) == 0 || waterRot.get(i+1) == 180) waterQueue.add(i+1);
        } else if (waterShape.get(i+1) == 2) {
          if (waterRot.get(i+1) == 0 || waterRot.get(i+1) == 270) waterQueue.add(i+1);
        } else if (waterShape.get(i+1) == 3) {
          if (waterRot.get(i+1) != 180) waterQueue.add(i+1);
        }
      } 
    }
  } else if (waterShape.get(i) == 3) {
    // up
    if (waterRot.get(i) == 90 || waterRot.get(i) == 0 || waterRot.get(i) == 180) {
      if (i-11 >= 0 && !waterOn.get(i-11)) {
        if (waterShape.get(i-11) == 1) {
          if (waterRot.get(i-11) == 90 || waterRot.get(i-11) == 270) waterQueue.add(i-11);
        } else if (waterShape.get(i-11) == 2) {
          if (waterRot.get(i-11) == 180 || waterRot.get(i-11) == 270) waterQueue.add(i-11);
        } else if (waterShape.get(i-11) == 3) {
          if (waterRot.get(i-11) != 90) waterQueue.add(i-11);
        }
      } 
    }
    // left
    if (waterRot.get(i) == 0 || waterRot.get(i) == 90 || waterRot.get(i) == 270) {
      if (i%11 != 0 && !waterOn.get(i-1)) {
        if (waterShape.get(i-1) == 1) {
          if (waterRot.get(i-1) == 0 || waterRot.get(i-1) == 180) waterQueue.add(i-1);
        } else if (waterShape.get(i-1) == 2) {
          if (waterRot.get(i-1) == 90 || waterRot.get(i-1) == 180) waterQueue.add(i-1);
        } else if (waterShape.get(i-1) == 3) {
          if (waterRot.get(i-11) != 0) waterQueue.add(i-1);
        }
      }
    } 
    //down
    if (waterRot.get(i) == 0 || waterRot.get(i) == 180 || waterRot.get(i) == 270) {
      if (i+11 < 66 && !waterOn.get(i+11)) {
        if (waterShape.get(i+11) == 1) {
          if (waterRot.get(i+11) == 90 || waterRot.get(i+11) == 270) waterQueue.add(i+11);
        } else if (waterShape.get(i+11) == 2) {
          if (waterRot.get(i+11) == 0 || waterRot.get(i+11) == 90) waterQueue.add(i+11);
        } else if (waterShape.get(i+11) == 3) {
          if (waterRot.get(i+11) != 270) waterQueue.add(i+11);
        }
      } 
    }
    //right
    if (waterRot.get(i) == 90 || waterRot.get(i) == 180 || waterRot.get(i) == 270) {
      if ((i+1)%11 != 0 && !waterOn.get(i+1)) {
        if (waterShape.get(i+1) == 1) {
          if (waterRot.get(i+1) == 0 || waterRot.get(i+1) == 180) waterQueue.add(i+1);
        } else if (waterShape.get(i+1) == 2) {
          if (waterRot.get(i+1) == 0 || waterRot.get(i+1) == 270) waterQueue.add(i+1);
        } else if (waterShape.get(i+1) == 3) {
          if (waterRot.get(i+1) != 180) waterQueue.add(i+1);
        }
      } 
    }
  }
}