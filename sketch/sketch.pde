public String img_path = "./snap.jpg";
public String deepthmap_path = "./snap.deepmap.jpg";
public int resolutionX = 260;
public int maxDepth = 400;
public float rotationFactor = .3;
public float dotThicknessFactor = 1.2;
public float highlightFactor = .1;

// DO NOT CHANGE ANYTHING BELOW THIS LINE
// ---------------------------------------
PImage bg, flare, flare2, img, map;
int resolutionY;
int highlightRow = 0;

void setup() {
  
  bg = loadImage("./bg.jpg");
  flare = loadImage("./flare.png");
  
  flare2 = loadImage("./flare2.png");
  img = loadImage(img_path);
  map = loadImage(deepthmap_path);

  size(800,800,P3D);
  noStroke();
  
  // image dimension/resolution handling
  float dimensionToResolutionFactor = parseFloat(resolutionX)/img.width;
  resolutionY = parseInt(img.height * dimensionToResolutionFactor /2); // calculate Y resolution
  // resize images to calculated resolution
  bg.resize(width,height);
  flare.resize(parseInt(width/1.2),parseInt(height/1.2));
  flare2.resize(parseInt(width/1.2),parseInt(height/1.2));
  img.resize(resolutionX, resolutionY);
  map.resize(resolutionX, resolutionY);
}

void draw() {
  // move anker to middle of the canvas
  translate(width/2, height/2, -300);
  
  // rotate depending on mouse position
  float mX = ((float) mouseX/width-.5)*rotationFactor*TWO_PI;
  float mY = ((float) mouseY/height-.5)*-rotationFactor*TWO_PI;
  rotateY(mX);
  rotateX(mY);
  
  drawImage();
  translate(0,0,maxDepth*0.8);
  imageMode(CENTER);
  image(flare2,0,0);
  translate(0,0,maxDepth*0.2);
  image(flare,0,0);
  
  highlightRow = (int)random(resolutionY*10);//(highlightRow+30) % (resolutionY*15); // change highlighted row (with rotation)
  //saveFrame(); // save animation
}

void drawImage() {
   background(bg);
   // grid
   int highlightRowAmount = (int)random(1,3);
   for(int x = 0;x<resolutionX;x++)
    for(int y = 0;y<resolutionY;y++) {
      
      color pixelColor = img.get(x,y); // get color for pixel
      float greyValue = dotThicknessFactor* map((red(pixelColor) + green(pixelColor) + blue(pixelColor))/(255.0*3),0,1,.5,.85); // calculate brightness as dot weight (dotThicknessFactor * [0-1])
      float depth = 1-((red(map.get(x,y)) + green(map.get(x,y)) + blue(map.get(x,y)))/(255.0*3)); // get 
      float w = sin(PI*x/(resolutionX-1))*sin(PI*y/(resolutionY-1));
      
      // highlighting
      float specificHighlightFactor = (float)2-((float)Math.abs(y-highlightRow)/highlightRowAmount);
      specificHighlightFactor = (specificHighlightFactor > 0) ? specificHighlightFactor : 0;
      //float specificHighlightFactor = (y == highlightRow) ? highlightFactor : 1; // activate for just one line highlight
      depth *= (float)1 + highlightFactor*specificHighlightFactor; // for repositioning of highlighted pixels
      pixelColor *= (float)1 + highlightFactor*specificHighlightFactor; // make highlighted pixel colorful
      
      pushMatrix();
      translate(0,0,depth*maxDepth); // move forward/backwarts
      fill(red(pixelColor), green(pixelColor), blue(pixelColor), w*255);
      
      // draw the ellipse(s)
      ellipse(
        (x*((float)width/resolutionX)) - width/2, // x-Position
        (y*((float)height/resolutionY)) - height/2,// y-Position
        (width/resolutionX)*(1.5*greyValue), // width
        (height/resolutionX)*(1.5*greyValue) // height
      );
      popMatrix();
    }
}