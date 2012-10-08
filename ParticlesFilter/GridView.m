#import "GridView.h"
#import "Robot.h"
#import "Particle.h"

#import <QuartzCore/QuartzCore.h>

@implementation GridView

@synthesize shouldAnimate;

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      cellSize = CGSizeMake(5, 5);
      
      self.shouldAnimate = NO;
      
      numOfRows = self.frame.size.height / cellSize.height;
      numOfCols = self.frame.size.width  / cellSize.width;
      
      overlayView = [[UIView alloc] initWithFrame:self.frame];
      [overlayView setBackgroundColor:[UIColor clearColor]];
      particlesCounter = malloc(numOfRows * sizeof(int *));
      particlesViews = [[NSMutableArray alloc] init];
      
      // Setup the cells
      cells = malloc(numOfRows * sizeof(int *));
      int y = 0;
      for (int row = 0; row < numOfRows; row++) {
         cells[row] = malloc(numOfCols * sizeof(int));
         particlesCounter[row] = malloc(numOfCols * sizeof(int));
         int x = 0;
         for (int col = 0; col < numOfCols; col++) {
            
            particlesCounter[row][col] = 0;
            
            int isBlock = isABlock(row, col, numOfRows, numOfCols);
            
            UIColor *color;
            if (isBlock)
               color = BLOCK_COLOR;
            else
               color = NON_BLOCK_COLOR;

            UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(x, y, cellSize.width, cellSize.height)];
            [cell setBackgroundColor:color];
            [self addSubview:cell];
            [cell release];
            
            cells[row][col] = isBlock;
            
            x += cellSize.width;
         }
         y += cellSize.height;
      }
      
      [self addSubview:overlayView];
      
      robot = nil;
      robotView = nil;
   }
   return self;
}

- (void) dealloc
{
   for (int row = 0; row < numOfRows; row++) {
      free(cells[row]);
      free(particlesCounter[row]);
   }
   free(cells);
   free(particlesCounter);
   free(particlesLocations);
   
   [robot release];
   [robotView release];
   [particlesViews release];
   [overlayView release];
   [super dealloc];
}

- (int **)world
{
   return cells;
}
- (CGSize)worldSize
{
   return CGSizeMake(numOfCols, numOfRows);
}

- (void)addRobot:(Robot *)obj
{
   if (robot) {
      [robot release];
      [self resetParticlesCounter];
      [[overlayView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
      [particlesViews removeAllObjects];
      free(particlesLocations);
   }
   robot = [obj retain];
   
   particlesLocations= malloc(robot.numOfParticles * sizeof(CGPoint));

   for (int i = 0; i < robot.numOfParticles; i++) {
         
      UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:PARTICLE_IMAGE_NAME]];
      imgView.center = CGPointMake(-20, -20); // put it outside the view's bound
      [overlayView addSubview:imgView];
      [particlesViews addObject:imgView];
      particlesLocations[i] = imgView.center;
      [imgView release];
   }
   
   int xPos = arc4random() % numOfCols;
   int yPos = arc4random() % numOfRows;
   // make sure this is not a block position
   while (cells[yPos][xPos]) {
      xPos = arc4random() % numOfCols;
      yPos = arc4random() % numOfRows;
   }
   // The particles' coordinates are in the x-y plane, not in the iOS screen coordinates
   // We'll use the screen as the botton-right quarter of the x-y plane, so we need to negate the y coordinate
   yPos *= -1;
   [robot setLocationX:xPos andY:yPos];
   
   [self updateRobotView];
   
   [self updateRobotParticlesViews];
}

- (void)letRobotSense
{
   [robot senseWorld:cells];
   [self updateRobotParticlesViews];
}

- (void)letRobotTurn:(float)radians thenMoveDist:(int)distance
{
   int oldX = robot.x, oldY = robot.y;
   [robot turn:radians thenMove:distance inWorld:cells];
   
   int didntMove = oldX == robot.x && oldY == robot.y;
   if (!didntMove) {
      [self updateRobotView];
      [self updateRobotParticlesViews];      
   }
}

- (void)animateRobot:(NSNumber *)sleepInterval
{
   NSTimeInterval time = [sleepInterval floatValue];
   float turn = 0.0f;
   
   while (shouldAnimate)
   {
      
      int oldX = robot.x, oldY = robot.y;
      
      [self letRobotTurn:turn thenMoveDist:1];
      
      int didntMove = oldX == robot.x && oldY == robot.y;
      while (didntMove)
      {
         float flag = arc4random() / (powf(2.0f, 32.0f) - 1.0f);
         
         if (flag >= 0.5f)
            turn = M_PI_2;
         else
            turn = -M_PI_2;
         
         [self letRobotTurn:turn thenMoveDist:1];
         
         didntMove = oldX == robot.x && oldY == robot.y;
      }
      
      [self letRobotSense];
      turn = 0.0f;
      
      [NSThread sleepForTimeInterval:time];      
   }
}

- (void)updateRobotParticlesViews
{
   struct Particle *particles = [robot particles];
   int numOfParticles = [robot numOfParticles];
   
   // Reset the number of particles at each cell
   [self resetParticlesCounter];
   
   // Count the number of particles at each cell
   [self setParticlesCounter];
   
   float cellHalfWidth = cellSize.width / 2.0f;
   float cellHalfHeight= cellSize.height/ 2.0f;
   
   for (int i = 0; i < numOfParticles; i++) {
      
      struct Particle p = particles[i];
      int yIndex = p.y * -1;
      
      // Make sure its within the view's bounds
      if (p.x >= 0 && p.y <= 0 && p.x <= numOfCols && yIndex < numOfRows)
      {
         // Form an X-shape if lots of particles are on a single cell
         
         float centerShift = 0.01f * particlesCounter[yIndex][p.x] / 2.0f;
         float xShift, yShift;
         
         int flag = arc4random_uniform(4);
         switch (flag) {
            case 0:
               xShift = centerShift * -1.0f;
               yShift = centerShift * -1.0f;
               break;
            case 1:
               xShift = centerShift * -1.0f;
               yShift = centerShift;
               break;
            case 2:
               xShift = centerShift;
               yShift = centerShift * -1.0f;
               break;
            default:
               xShift = centerShift;
               yShift = centerShift;
         }
         
         CGPoint newCenter = CGPointMake(p.x * cellSize.width + cellHalfWidth + xShift, yIndex * cellSize.height + cellHalfHeight + yShift);
         particlesLocations[i] = newCenter;
         
         particlesCounter[yIndex][p.x] = particlesCounter[yIndex][p.x] - 1;
      }
   }
   
   [self performSelectorOnMainThread:@selector(setParticlesViewsCenters) withObject:nil waitUntilDone:YES];
}

- (void)updateRobotView
{
   CGPoint newCenter = CGPointMake(robot.x * cellSize.width + (cellSize.width / 2.0f), robot.y * -1.0f * cellSize.height + (cellSize.height / 2.0f));
   
   if (!robotView) {
      robotView = [[UIImageView alloc] initWithImage:[robot image]];
      robotView.center = newCenter;
      robotView.transform = CGAffineTransformMakeRotation(robot.orientation);
      [self addSubview:robotView];
   }
   else {
      [self performSelectorOnMainThread:@selector(animateMovingRobot:) withObject:[NSValue valueWithCGPoint:newCenter] waitUntilDone:YES];
   }
}

- (void)animateMovingRobot:(NSValue *)data
{
   CGPoint newCenter = [data CGPointValue];
   
   [UIView animateWithDuration:0.2
                         delay:0.0
                       options: UIViewAnimationCurveEaseInOut
                    animations:^{
                       robotView.center = newCenter;
                       robotView.transform = CGAffineTransformMakeRotation(robot.orientation);
                    }
                    completion:^(BOOL finished){
                    }
    ];
}

- (void)setParticlesViewsCenters
{
   int numOfParticles = robot.numOfParticles;
   for (int i = 0; i < numOfParticles; i++) {
      UIImageView *imgView = [particlesViews objectAtIndex:i];
      imgView.center  = particlesLocations[i];
   }
}

- (void)setParticlesCounter
{
   struct Particle *particles = [robot particles];
   int numOfParticles = robot.numOfParticles;
   
   for (int i = 0; i < numOfParticles; i++) {
      struct Particle p = particles[i];
      int yIndex = p.y * -1;
      // Make sure it's within the view's bounds
      if (p.x >= 0 && p.y <= 0 && p.x <= numOfCols && yIndex < numOfRows)
      {
         particlesCounter[yIndex][p.x] = particlesCounter[yIndex][p.x] + 1;
      }
   }
}

- (void)resetParticlesCounter
{
   for (int row = 0; row < numOfRows; row++) {
      for (int col = 0; col < numOfCols; col++) {
         particlesCounter[row][col] = 0;
      }
   }
}

int isABlock(int row, int col, int numOfRows, int numOfCols)
{
   // edges
   int isABlock = row ==0 || col == 0 || row + 1 == numOfRows || col + 1 == numOfCols;
   if (isABlock)
      return 1;
   
   // top-left room
   isABlock = (row <= 20 && col == 20) || (row == 20 && (col < 20 && (col < 7 || col > 10)));
   if (isABlock)
      return 1;
   
   // top-right roon
   isABlock = (col == 31 && row <= 11 && (row < 5 || row > 7)) || (row == 11 && col > 31 && (col < 54 || col > 57));
   if (isABlock)
      return 1;
   
   // middle-right room
   isABlock = (col == 28 && row >= 26 && row <= 45) || (row == 26 && ((col >= 28 && col <= 43) || (col >= 48))) || (col >= 44 && col <= 48 && (row == 30 || row == 31)) || (col >= 35 && col <= 39 && (row >= 39 && row <= 41)) || (row == 45 && col >= 33);
   if (isABlock)
      return 1;
   
   // mid-left 1st block
   isABlock = (row >= 25 && row <= 31 && col == 7) || (row >= 26 && row <= 30 && (col == 6 || col == 8)) || (row >= 27 && row <= 29 && (col == 9 || col == 5)) || (row == 28 && (col == 10 || col == 4));
   if (isABlock)
      return 1;
   
   // mid-left wall
   isABlock = (row == 37 && col >= 5 && col <= 22);
   if (isABlock)
      return 1;
   
   // mid-left 2nd block
   isABlock = (row >= 45 && row <= 48 && col >= 11 && col <= 18);
   if (isABlock)
      return 1;
   
   isABlock = (row == 52 && (col <= 36 || col >= 42)) || (row >= 52+5 && col == 33) || (row >= 52 && row <= numOfRows - 6 && col == 50) || (row >= 58 && row <= 62 && col >= 10 && col <= 17);
   if (isABlock)
      return 1;
      
   return 0;
}

@end
