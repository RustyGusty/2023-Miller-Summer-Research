# Timeline
Documentation of the items completed on each day

## 2024-04-29
- Initial Task: Create outer framework for main scan loop, including connecting to the PI delay stage and stepping through delay stage positions
- Additional Task: Redo the GUI, using the original motioncapture.m as a template
- Created controlgui template for the GUI
- Using motioncontrol.m and picontrol.m, started scanloop.m
- Error checking on initial and final positions (needs confirmation of how the delay stage connection will be)

## 2024-05-01
- Prepared connection to delay stage
- Various controlgui bits and bobs for editing delay stage properties
- Prepared testing button to run
### Change: discarding controlgui, using modified version of motioncontrol instead
- Added abort functionality
- Improved interfacing with the user with error messages and dialogue
- Packaging some functions into one (e.g. enabling and disabling fields.)
- Added beforeim and afterim functionality

## 2024-05-02
- Removed initiating CCD acquisition and opening shutters in the goscan_callback function (implemented directly in take image)
- Enabled GUI interaction with goscan (scanstartd for initial position, scanstepd for step distance, nstepd for number of steps, and numberscans for number of times to run the scan all the way through)
- Testing in the lab to confirm movement of the delay stage (correctly assumed that the return values of the DS were in mm, not m as the previous code suggested)
- Finished goscan loop, displaying messages for moving the delay stage according to the number of steps and the queue for how many images will be taken.

## 2024-05-10
- Changed the goscan loop so that numberscans instead dictates how many photos are taken at each delay stage position
- Changed numberscans to be how many pump on and pump off photos are taken rather than total photos (aka *2)
- In image_analysis, added two additional features:
1. One to toggle between grayscale and jet for the display color
2. One to display the delta image when scanning using goscan (difference between the currently taken image and the new image to determine if a change exists) -- Note: need testing on actual data to figure out if the delta image works as expected, since currently all images are identical
- Organized the photos into 'runs' representing each of the scan runs, and within each run, two separate folders, one for the pump off photos and one for the pump on photos (1 and 2)
- Added additional unmodifiable text boxes to display the run number (firsts available number) and the subfolder number (alternating between 1 and 2)
- Added a radio button in the GUI to determine which of 1 and 2 are the pump on photos. This comes alongside a prompt before initiating the photo taking process to have someone confirm the initial shutter status.
- Prevented a user from unpressing the abort button by pressing twice

## 2024-05-11
- Added renaming functionality to the folders to automatically sort the folders based on the user's selection of the radio button


