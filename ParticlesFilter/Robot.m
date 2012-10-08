#import "Robot.h"

@implementation Robot

@synthesize x, y, orientation;

- (id)initInWorld:(int **)world
withNumberOfParticles:(int)n
        WorldSize:(CGSize)aSize
   andMovingNoise:(float)mNoise
   andSensorNoise:(float)sNoise
  andTurningNoise:(float)tNoise
   andSensorRange:(int)sr
{
   self = [super init];
   if (self) {
      world_y_max = aSize.height;
      world_x_max = aSize.width;
      
      move_noise   = mNoise;
      sensor_noise = sNoise;
      turn_noise   = tNoise;
      sensor_range = sr;
      
      orientation = 0.0f;
      
      // initialize the particles
      numOfParticles = n;
      particles = malloc(numOfParticles * sizeof(struct Particle));
      newParticles = malloc(numOfParticles * sizeof(struct Particle));
      particlesWeights = malloc(numOfParticles * sizeof(double));
      
      for (int i = 0; i < numOfParticles; i++) {
         int px = arc4random_uniform(world_x_max);
         int py = arc4random_uniform(world_y_max);
         while (world[py][px]) {
            // Don't init them on a block
            px = arc4random_uniform(world_x_max);
            py = arc4random_uniform(world_y_max);
         }
         py *= -1;
         float porientation = arc4random() / ((pow(2, 32)-1)) * M_PI*2;
         struct Particle p = {.x=px, .y=py, .orientation=porientation};
         particles[i] = p;
      }
   }
   return self;
}

- (void)dealloc
{
   free(particles);
   free(newParticles);
   free(particlesWeights);
   [super dealloc];
}

- (void)setLocationX:(int)aX andY:(int)aY
{
   x = aX;
   y = aY;
}

- (struct Particle *)particles
{
   return particles;
}

- (int)numOfParticles
{
   return numOfParticles;
}

- (UIImage *) image
{
   return [UIImage imageNamed:@"robot.png"];
}

- (void)turn:(float)radians
    thenMove:(int)distance
     inWorld:(int **)world
{
   // Move self then move the particles
   
   // Calculate the new orientation
   float two_pi = 2.0f * M_PI;
   float newOrientation = fmodf((orientation + radians + randomGaussian(0.0f, turn_noise)), two_pi);
   
   // Calculate the new position
   float dist = distance + randomGaussian(0.0f, move_noise);
   int newY = (y + floorf(cosf(newOrientation) * dist + 0.5f));
   int newX = (x + floorf(sinf(newOrientation) * dist + 0.5f));
   if (newX < 0 || (newY*-1) < 0 || newX >= world_x_max || (newY*-1) >= world_y_max || world[newY*-1][newX] == 1) {
      // illegal move
      return;
   }
   // TO-DO: Check for moves that are more than one step, the robot may jump over a block.
   
   orientation = newOrientation;
   x = newX;
   y = newY;
   
   // move the particles
   for (int i = 0; i < numOfParticles; i++) {
      struct Particle p = particles[i];
      
      p.orientation = fmodf((p.orientation + radians + randomGaussian(0.0f, turn_noise)), two_pi);
      p.y += floorf(cosf(p.orientation) * dist + 0.5f);
      p.x += floorf(sinf(p.orientation) * dist + 0.5f);
      
      particles[i] = p;
   }
}

- (void)senseWorld:(int **)world
{
   // 1. Measure the distances to 4 locations:
   //    1.1. The nearest block in front
   //    1.2. The nearest block on the right
   //    1.3. The nearest block on the back
   //    1.4. The nearest block on the left
   static const int numOfMeasurements = 4;
   float turn = M_PI_2;
   const int dist = 1;
   
   float measurements[numOfMeasurements];
   int mX = x, mY = y;
   float mOri = orientation;
   
   for (int i = 0; i < numOfMeasurements; i++) {
      mY = mY + floorf(cosf(mOri) * dist + 0.5f);
      mX = mX + floorf(sinf(mOri) * dist + 0.5f);
      int steps = 1;
      while (steps < sensor_range && world[mY * -1][mX] == 0) {
         steps++;
         mY += floorf(cosf(mOri) * dist + 0.5f);
         mX += floorf(sinf(mOri) * dist + 0.5f);
      }
      measurements[i] = distance(x, mX, y, mY) + randomGaussian(0.0f, sensor_noise);
      
      mOri += turn;
      mX = x, mY = y;
   }
   
   // 2. Using the measurements in 1, calculate the importance weights of the particles   
   double weightsSum= 0.0;
   float pMeasurements[numOfMeasurements];
   for (int i = 0; i < numOfParticles; i++) {
      struct Particle p = particles[i];
      
      // calculate the particle measurements
      int pX = p.x, pY = p.y;
      
      if (pX < 0 || pY > 0 || pX >= world_x_max || (pY * -1) >= world_y_max || world[pY * -1][pX])
      {
         // it's either outside the world, or it's already on a block, so give it a weight of 0.0
         particlesWeights[i] = 0.0;
      }
      
      else
      {
         float pOri = p.orientation;
         for (int j = 0; j < numOfMeasurements; j++)
         {
            pY = pY + floorf(cosf(pOri) * dist + 0.5f);
            pX = pX + floorf(sinf(pOri) * dist + 0.5f);
            int steps = 1;
            while (steps < sensor_range && world[pY * -1][pX] == 0) {
               steps++;
               pY = pY + floorf(cosf(pOri) * dist + 0.5f);
               pX = pX + floorf(sinf(pOri) * dist + 0.5f);
            }
            pMeasurements[j] = distance(p.x, pX, p.y, pY) + randomGaussian(0.0f, sensor_noise);
            
            pOri += turn;
            pX = p.x, pY = p.y;
         }
         
         // calculate its weight
         particlesWeights[i] = measurementsProbability(p, pMeasurements, measurements, numOfMeasurements, sensor_noise);

      }
      weightsSum += particlesWeights[i];
   }
   
   // Normalize the weights
   double maxWeight = 0.0;
   for (int i = 0; i < numOfParticles; i++) {
      particlesWeights[i] = particlesWeights[i] / weightsSum;
      if (particlesWeights[i] > maxWeight)
         maxWeight = particlesWeights[i];
   }

   // 3. Resample the particles
   int index = arc4random_uniform(numOfParticles);
   double beta = 0.0;
   double maxWeight2 = maxWeight * 2.0;
   for (int i = 0; i < numOfParticles; i++) {
      
      beta += (arc4random() / (pow(2, 32)-1) * maxWeight2);
      while (beta > maxWeight2)
         beta -= maxWeight2;
      
      while (beta > particlesWeights[index]) {
         beta -= particlesWeights[index];
         index++;
         if (index == numOfParticles)
            index = 0;
      }
      
      newParticles[i] = particles[index];
   }
   
   // let particles point to the newParticles
   struct Particle *tmp = particles;
   particles = newParticles;
   newParticles = tmp;
   tmp = NULL;
}

#pragma mark -
#pragma mark - Helper functions

float distance(int x1, int x2, int y1, int y2)
{
   int diffX = x1 - x2;
   int diffY = y1 - y2;
   return sqrt(diffX * diffX + diffY * diffY);
}

float randomGaussian(float mean, float sd)
{
   return mean + sd * sqrtf(-2.0f * logf((rand() + 1.0f) / (RAND_MAX + 1.0f))) * cosf(2.0f * M_PI * (rand() + 1.0f) / (RAND_MAX + 1.0f));
}

double measurementsProbability(struct Particle p, float *pMeasurements, float *measurements, int numMeasurements, float noise)
{
   double prob = 1.0;
   
   float sigma = noise;
   float sigmaSquared = sigma * sigma;
   
   for (int i = 0; i < numMeasurements; i++) {
      // calculate the probability of x for 1-dim Gaussian with mean mu and var. sigma
      float x = measurements[i];
      float mu = pMeasurements[i];
      float diffMuX = mu - x;
      
      prob = prob * expf(- (diffMuX * diffMuX) / sigmaSquared / 2.0f) / sqrtf(2.0f * M_PI * sigmaSquared);
   }
   
   return prob;
}

@end
