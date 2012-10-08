
#define BLOCK_COLOR [UIColor colorWithRed:205/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:255.0/255.0f]
#define NON_BLOCK_COLOR [UIColor colorWithRed:20.0f/255.0f green:80.0f/255.0f blue:130.0f/255.0f alpha:255.0/255.0f]

@class Robot;

@interface GridView : UIView {
   int **cells;
   CGSize cellSize;
   int numOfRows;
   int numOfCols;
   
   UIView *overlayView; // Contains the particles' views
   NSMutableArray *particlesViews;
   int **particlesCounter; // Counts the number of particles in each cell
   CGPoint *particlesLocations;
   
   Robot *robot;
   UIImageView *robotView;
}

@property (assign) BOOL shouldAnimate;

- (int **)world;
- (CGSize)worldSize;
- (void)addRobot:(Robot *)obj;

- (void)animateRobot:(NSNumber *)sleepInterval;
- (void)letRobotSense;
- (void)letRobotTurn:(float)radians thenMoveDist:(int)dist;

@end
