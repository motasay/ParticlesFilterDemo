#import "Particle.h"

@interface Robot : NSObject {
   int world_y_max;
   int world_x_max;
   
   float orientation;
   int x, y; // The robot's/particles' coordinates are in the x-y
             // plane, not in the iOS screen coordinates. We'll use the
             // screen as the botton-right quarter of the x-y plane,
             // so the x coordinate will always be >= 0, and y-coordinate
             // will always be <= 0
   
   float move_noise, turn_noise, sensor_noise;
   int sensor_range;

   struct Particle *particles;
   struct Particle *newParticles; // Needed during resampling
   double *particlesWeights;
   int numOfParticles;
}

@property (readonly) int x;
@property (readonly) int y;
@property (readonly) float orientation;

- (id)initInWorld:(int **)world
withNumberOfParticles:(int)n
        WorldSize:(CGSize)aSize
   andMovingNoise:(float)pNoise
   andSensorNoise:(float)sNoise
  andTurningNoise:(float)tNoise
   andSensorRange:(int)sr;

- (void)setLocationX:(int)aX andY:(int)aY;

- (struct Particle *)particles;
- (int)numOfParticles;

- (void)turn:(float)radians thenMove:(int)distance inWorld:(int **)world;
- (void)senseWorld:(int **)world;

- (UIImage *)image;

@end
