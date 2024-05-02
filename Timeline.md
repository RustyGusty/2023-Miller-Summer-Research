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
- Change: discarding controlgui, using modified version of motioncontrol instead
- Added abort functionality
- Improved interfacing with the user with error messages and dialogue
- Packaging some functions into one (e.g. enabling and disabling fields.)
- Added beforeim and afterim functionality

