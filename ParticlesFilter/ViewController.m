#import "ViewController.h"
#import "Robot.h"
#import "GridView.h"

@implementation ViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
	
   self.settingsView.hidden = YES;
   
   // Default values.
   numOfParticles = 3000;
   move_noise = 0.35f;
   turn_noise = 0.35f;
   sense_noise= 4.99f;
   sensor_range = 20;
   animation_sleep_interval = 0.5f;
   
   self.turnSlider.value = 0.0f;
   self.turnSlider.minimumValue = -M_PI_2;
   self.turnSlider.maximumValue = M_PI_2;
   
   self.numParticlesSlider.minimumValue = 1;
   self.numParticlesSlider.maximumValue = 5000;
   
   self.moveNoiseSlider.minimumValue = 0.01;
   self.moveNoiseSlider.maximumValue = 4.99;
   
   self.turnNoiseSlider.minimumValue = 0.01;
   self.turnNoiseSlider.maximumValue = 4.99;
   
   self.senseNoiseSlider.minimumValue = 0.01;
   self.senseNoiseSlider.maximumValue = 4.99;
   
   self.senseRangeSlider.minimumValue = 1;
   self.senseRangeSlider.maximumValue = 50;
   
   self.animationSleepSlider.minimumValue = 0.0;
   self.animationSleepSlider.maximumValue = 10.0;
   
   grid = nil;
   [self initGrid];
}

- (void)viewDidUnload
{
   [super viewDidUnload];
   
   [grid release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) initGrid
{
   if (grid) {
      [grid removeFromSuperview];
      [grid release];
   }
   
   CGRect gridFrame    = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100); // 100 for the controls view
   grid = [[GridView alloc] initWithFrame:gridFrame];
   
   // Init a robot with the motion_success & sensor_success parameters
   Robot *obj = [[Robot alloc] initInWorld:[grid world] withNumberOfParticles:numOfParticles WorldSize:[grid worldSize] andMovingNoise:move_noise andSensorNoise:sense_noise andTurningNoise:turn_noise andSensorRange:sensor_range];

   // Add the robot to the grid.
   [grid addRobot:obj];
   [obj release];
   
   // Display the grid.
   [self.view addSubview:grid];
   [self.view bringSubviewToFront:grid];
}

- (IBAction)sense:(id)sender
{
   [grid letRobotSense];
}
- (IBAction)move:(id)sender
{
   [grid letRobotTurn:self.turnSlider.value thenMoveDist:1];
   self.turnSlider.value = 0.0f;
   self.turnView.transform = CGAffineTransformMakeRotation(self.turnSlider.value);
}
- (IBAction)animate:(id)sender
{
   if (grid.shouldAnimate)
   {
      // Stop the animation
      grid.shouldAnimate = NO;
      [self.animateButton setTitle:@"Animate" forState:UIControlStateNormal];
      self.settingsButton.enabled = YES;
      self.moveButton.enabled     = YES;
      self.senseButton.enabled    = YES;
      self.turnSlider.enabled     = YES;      
   }
   else
   {
      [self.animateButton setTitle:@"Stop" forState:UIControlStateNormal];
      grid.shouldAnimate = YES;
      self.settingsButton.enabled = NO;
      self.moveButton.enabled     = NO;
      self.senseButton.enabled    = NO;
      self.turnSlider.enabled     = NO;
      [NSThread detachNewThreadSelector:@selector(animateRobot:) toTarget:grid withObject:[NSNumber numberWithFloat:animation_sleep_interval]];
   }
}

- (IBAction)showSettings:(id)sender
{
   [self.view bringSubviewToFront:self.settingsView];

   [self.numParticlesLabel setText:[NSString stringWithFormat:@"%d", numOfParticles]];
   [self.moveNoiseLabel setText:[NSString stringWithFormat:@"%.2f", move_noise]];
   [self.turnNoiseLabel setText:[NSString stringWithFormat:@"%.2f", turn_noise]];
   [self.senseNoiseLabel setText:[NSString stringWithFormat:@"%.2f", sense_noise]];
   [self.senseRangeLabel setText:[NSString stringWithFormat:@"%d", sensor_range]];
   [self.animationSleepLabel setText:[NSString stringWithFormat:@"%.1f", animation_sleep_interval]];
   [self.numParticlesSlider setValue:numOfParticles];
   [self.moveNoiseSlider setValue:move_noise];
   [self.turnNoiseSlider setValue:turn_noise];
   [self.senseNoiseSlider setValue:sense_noise];
   [self.senseRangeSlider setValue:sensor_range];
   [self.animationSleepSlider setValue:animation_sleep_interval];
   self.settingsView.hidden = NO;
}

- (IBAction)saveSettings:(id)sender
{
   [self initGrid];
   self.settingsView.hidden = YES;
}
- (IBAction)numberOfParticlesChanged:(id)sender
{
   numOfParticles = (int) ((UISlider *)sender).value;
   [self.numParticlesLabel setText:[NSString stringWithFormat:@"%d", numOfParticles]];
}
- (IBAction)moveNoiseChanged:(id)sender
{
   move_noise = ((UISlider *)sender).value;
   [self.moveNoiseLabel setText:[NSString stringWithFormat:@"%.2f", move_noise]];
}
- (IBAction)turnNoiseChanged:(id)sender
{
   turn_noise = ((UISlider *)sender).value;
   [self.turnNoiseLabel setText:[NSString stringWithFormat:@"%.2f", turn_noise]];
}
- (IBAction)senseNoiseChanged:(id)sender
{
   sense_noise = ((UISlider *)sender).value;
   [self.senseNoiseLabel setText:[NSString stringWithFormat:@"%.2f", sense_noise]];
}

- (IBAction)turnChanged:(id)sender
{
   self.turnView.transform = CGAffineTransformMakeRotation(self.turnSlider.value);
}

- (IBAction)senseRangeChanged:(id)sender
{
   sensor_range = ((UISlider *)sender).value;
   [self.senseRangeLabel setText:[NSString stringWithFormat:@"%d", sensor_range]];
}

- (IBAction)animationSleepIntervalChanged:(id)sender
{
   animation_sleep_interval = ((UISlider *)sender).value;
   [self.animationSleepLabel setText:[NSString stringWithFormat:@"%.1f", animation_sleep_interval]];
}

@end
