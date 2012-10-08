@class GridView;

@interface ViewController : UIViewController {
   GridView *grid;
      
   int numOfParticles;
   float move_noise, sense_noise, turn_noise, animation_sleep_interval;
   int sensor_range;
}

@property (retain, nonatomic) IBOutlet UIView *settingsView;
@property (retain, nonatomic) IBOutlet UIImageView *turnView;
@property (retain, nonatomic) IBOutlet UISlider *turnSlider;

@property (retain, nonatomic) IBOutlet UILabel *numParticlesLabel;
@property (retain, nonatomic) IBOutlet UILabel *moveNoiseLabel;
@property (retain, nonatomic) IBOutlet UILabel *turnNoiseLabel;
@property (retain, nonatomic) IBOutlet UILabel *senseNoiseLabel;
@property (retain, nonatomic) IBOutlet UILabel *senseRangeLabel;
@property (retain, nonatomic) IBOutlet UILabel *animationSleepLabel;

@property (retain, nonatomic) IBOutlet UISlider *numParticlesSlider;
@property (retain, nonatomic) IBOutlet UISlider *moveNoiseSlider;
@property (retain, nonatomic) IBOutlet UISlider *turnNoiseSlider;
@property (retain, nonatomic) IBOutlet UISlider *senseNoiseSlider;
@property (retain, nonatomic) IBOutlet UISlider *senseRangeSlider;
@property (retain, nonatomic) IBOutlet UISlider *animationSleepSlider;

@property (retain, nonatomic) IBOutlet UIButton *settingsButton;
@property (retain, nonatomic) IBOutlet UIButton *animateButton;
@property (retain, nonatomic) IBOutlet UIButton *moveButton;
@property (retain, nonatomic) IBOutlet UIButton *senseButton;

- (IBAction)sense:(id)sender;
- (IBAction)move:(id)sender;
- (IBAction)animate:(id)sender;

- (IBAction)turnChanged:(id)sender;

- (IBAction)showSettings:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)numberOfParticlesChanged:(id)sender;
- (IBAction)moveNoiseChanged:(id)sender;
- (IBAction)turnNoiseChanged:(id)sender;
- (IBAction)senseNoiseChanged:(id)sender;
- (IBAction)senseRangeChanged:(id)sender;
- (IBAction)animationSleepIntervalChanged:(id)sender;

@end
