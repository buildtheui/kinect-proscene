import remixlab.proscene.*;
import remixlab.proscene.*;
import remixlab.bias.*;
import remixlab.bias.event.*;
import remixlab.dandelion.geom.*;
import remixlab.dandelion.core.*;

import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

Scene mainScene;

PGraphics canvas, kinectCanvas;
InteractiveFrame iFrame;
boolean firstPerson;
HIDAgent hidAgent;
static int SN_ID;

// Kinect Library object
KinectTrack kinectAgent;

float maxThreshX = 320;
float maxThreshY = 240;
float centerThreshX = (maxThreshX)/2;
float centerThreshY = (maxThreshY)/2;
float centerThreshZ = 10500;
float centerOffsetX = 50;
float centerOffsetY = 30;
float centerOffsetZ = 1000;

float defaultZPosition = 0;
float defaultXPosition = 0;
float defaultYPosition = 0;

float defaultYRotate = 0;
float defaultZRotate = 0;

float rightHandX = 0;
float rightHandY = 0;
float rightHandZ = 0;

float leftHandX = 0;
float leftHandY = 0;



void setup() {
  size(1024, 720, P3D);
  canvas = createGraphics(width, height, P3D);    
  mainScene = new Scene(this, (PGraphics3D) canvas);  
  iFrame = new InteractiveFrame(mainScene);
  iFrame.translate(30, 30);
  //toggleFirstPerson();
  
  hidAgent = new HIDAgent(mainScene);
  kinectAgent = new KinectTrack(this);
  
  // we bound some frame DOF5 actions to the gesture on both frames
  mainScene.eyeFrame().setMotionBinding(SN_ID, "translateRotateXYZ");
  //iFrame.setMotionBinding(SN_ID, "translateXYZ");
  smooth();

  kinectAgent.setUpBodyData();
}

void draw() {
  
  
  mainScene.beginDraw();
  background(0);
  mainScene.pg().fill(204, 102, 0, 150);
  mainScene.drawTorusSolenoid();

  // Save the current model view matrix
  pushMatrix();
  // Multiply matrix to get in the frame coordinate system.
  // applyMatrix(mainScene.toPMatrix(iFrame.matrix())); //is possible but inefficient
  iFrame.applyTransformation();//very efficient
  // Draw an axis using the mainScene static function
  mainScene.drawAxes(20);

  // Draw a second torus
  if (mainScene.motionAgent().defaultGrabber() == iFrame) {
    mainScene.pg().fill(0, 255, 255);
    mainScene.drawTorusSolenoid();
  }
  else if (iFrame.grabsInput()) {
    mainScene.pg().fill(255, 0, 0);
    mainScene.drawTorusSolenoid();
  }
  else {
    mainScene.pg().fill(0, 0, 255, 150);
    mainScene.drawTorusSolenoid();
  } 
  popMatrix();
  mainScene.endDraw();
  mainScene.display();
  
  image(kinectAgent.kinect.GetDepth(), 0, 0, maxThreshX, maxThreshY);
  for (int i=0; i<kinectAgent.bodies.size (); i++) 
  {
    
    rightHandX = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).x * maxThreshX;
    rightHandY = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).y * maxThreshY;
    rightHandZ = kinectAgent.getRightHandPosition(kinectAgent.bodies.get(i)).z;
    
    leftHandX = kinectAgent.getLeftHandPosition(kinectAgent.bodies.get(i)).x * maxThreshX;
    leftHandY = kinectAgent.getLeftHandPosition(kinectAgent.bodies.get(i)).y * maxThreshY;
    
    processKinectRightHand(rightHandX, rightHandY, rightHandZ);
    processKinectLeftHand(leftHandX, leftHandY);
  }  
  
  
  
}

// processing translation movement
public void processKinectRightHand(float x , float y, float z){  
  
  // processing x translatation
  if(x > (centerThreshX + centerOffsetX))
    defaultXPosition = 0.3;
  if(x < (centerThreshX - centerOffsetX))
    defaultXPosition = -0.3;
  if(x > (centerThreshX - centerOffsetX) && x < (centerThreshX + centerOffsetX))
    defaultXPosition = 0;
  
  // processing y translatation
  if(y > (centerThreshY + centerOffsetY))
    defaultYPosition = 0.3;
  if(y < (centerThreshY - centerOffsetY))
    defaultYPosition = -0.3;
  if(y > (centerThreshY - centerOffsetY) && y < (centerThreshY + centerOffsetY))
    defaultYPosition = 0;
    
  // processing z translatation
  if(z > (centerThreshZ + centerOffsetZ)){
    defaultZPosition = -0.3;
    fill(255,246,2);    
    noStroke();
    ellipse(x, y, 10, 10);    
  }
  else if(z < (centerThreshZ - centerOffsetZ)){
    defaultZPosition = 0.3;
    fill(255,0,0);
    noStroke();
    ellipse(x, y, 50, 50);    
  }
  else if(z > (centerThreshZ - centerOffsetZ) && y < (centerThreshZ + centerOffsetZ)){
    defaultZPosition = 0;
    fill(0,255,0);
    noStroke();
    ellipse(x, y, 25, 25);
  }
   
  
}

// processing rotation movement
public void processKinectLeftHand(float x , float y){
  
  fill(150,0,255);
  noStroke();
  ellipse(x, y, 25, 25);
    
  // processing x Rotation (proxy of Z rotation, since x is actually 0)
  if(x > (centerThreshX + centerOffsetX))
    defaultZRotate = 0.3;
  if(x < (centerThreshX - centerOffsetX))
    defaultZRotate = -0.3;
  if(x > (centerThreshX - centerOffsetX) && x < (centerThreshX + centerOffsetX))
    defaultZRotate = 0;
  
  // processing y Rotation  
  if(y > (centerThreshY + centerOffsetY))
    defaultYRotate = 0.3;
  if(y < (centerThreshY - centerOffsetY))
    defaultYRotate = -0.3;
  if(y > (centerThreshY - centerOffsetY) && y < (centerThreshY + centerOffsetY))
    defaultYRotate = 0;
    
}

public void keyPressed() {
  if ( key == 'i')
    mainScene.inputHandler().shiftDefaultGrabber(mainScene.eyeFrame(), iFrame);
  if ( key == ' ')
    //toggleFirstPerson();
  if(key == '+')
    mainScene.eyeFrame().setFlySpeed(mainScene.eyeFrame().flySpeed() * 1.1);
  if(key == '-')
    mainScene.eyeFrame().setFlySpeed(mainScene.eyeFrame().flySpeed() / 1.1);
}


// kinect4WinSDK updating default methods
void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(kinectAgent.bodies) {
    kinectAgent.bodies.add(_s);
  }
}
 
void disappearEvent(SkeletonData _s) 
{
  synchronized(kinectAgent.bodies) {
    for (int i=kinectAgent.bodies.size ()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == kinectAgent.bodies.get(i).dwTrackingID) 
      {
        kinectAgent.bodies.remove(i);
      }
    }
  }
}
 
void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(kinectAgent.bodies) {
    for (int i=kinectAgent.bodies.size ()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == kinectAgent.bodies.get(i).dwTrackingID) 
      {
        kinectAgent.bodies.get(i).copy(_a);
        break;
      }
    }
  }
}