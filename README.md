This simple demo has been built during Udacity's CS373 "Programming A Robotic Car" class. It illustrates how a robot is localized using a **particles filter**. You can move the robot (The small, white, mosquito-like shape) and let it sense manually, or you can just click on animate to move it randomly and watch how the particles (The small red triangles) are resampled after each move-sense cycle.

### Details:
The screen is divided into a grid of size 72*64, this discretization of the screen is needed to reduce the number of particles needed to localize the robot. When particles come over the same grid cell, they will form a X-shape, the more they are, the bigger this X will be.

##### Parameters:
You can play with many parameters in the settings. The following is a simple description of each one:

![Screenshot 4](https://dl.dropbox.com/u/1693311/udacity/particles4.png)

* *Number of particles:* The more you have, the more likely the robot will be able to localize (and the worse the performance), and vice versa.
* *Sensor range:* This is the number of cells that the robot (and particles) will scan when they sense. The greater this number, the more likely the robot will localize, and vise versa.
* *Motion, turn and sense noise:* These parameters specify the variances of the gaussians that will be added to each move, turn or sense value, respectively.
* *Animation sleep interval:* For your convenience :)

##### Implementation Note:
1. The coordinates of the robot and the particles are in the x-y plane. And since the point (0, 0) represents the top-left point of the iOS screen, I am using the screen as the bottom-right space of the x-y plane, and hence the robot will always have an x coordinate >= 0 and a y-coordinate <= 0. This has the effect that the y coordinate must be negated (i.e. multiplied by -1) each time we need to change from screen-coordinates to robot/particle coordinates.
2. Because the world is divided into cells, the coordinates of the robot/particles will always by integers, not real numbers. This makes their movements a little inaccurate, because for example, if the robot has an orientation of 0.1, it will go to the cell upwards, so this orientation may not have an immediate effect, but it will eventually affect the position after more steps.

##### Note on the performance:
I've used the standard UIKit framework for the animation, and moving the particles' views by changing their center is a significant overhead. If you're interested in fixing this, I think OpenGL may be the way to go.

### Screenshots:

![Screenshot 1](https://dl.dropbox.com/u/1693311/udacity/particles1.png)

![Screenshot 2](https://dl.dropbox.com/u/1693311/udacity/particles2.png)

![Screenshot 3](https://dl.dropbox.com/u/1693311/udacity/particles3.png)


