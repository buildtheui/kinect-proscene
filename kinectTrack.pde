public class KinectTrack {
  Kinect kinect;
  ArrayList <SkeletonData> bodies;
  public static final int LEFT_HAND_ID = 7;
  public static final int RIGHT_HAND_ID = 11;
  
  public KinectTrack(PApplet p){
    kinect = new Kinect(p);    
  }

  public void setUpBodyData(){
    bodies = new ArrayList<SkeletonData>();
  }  

  public PVector getLeftHandPosition(SkeletonData s){
    return s.skeletonPositions[LEFT_HAND_ID];
  }

  public PVector getRightHandPosition(SkeletonData s){
    return s.skeletonPositions[RIGHT_HAND_ID];
  }

  
}