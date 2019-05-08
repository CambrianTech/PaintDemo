# PaintDemo

                   USING CAMBRIAN’S HOME AUGMENTATION SDK

 Cambrian Home Augmentation SDK
Implementation is made to be as simple as possible, handling computer vision and rendering tasks under the hood without interaction from the application. The entire core SDK is encapsulated within a single UIView that can be placed within a storyboard.
Primary components
•View
•
•Scene
• •
•Asset
  •
Generic parent type for remodeling types. Paint, floor, furniture, etc
Holds everything, manages state and lifecycle
Holds information about current image/video being edited Assets, lighting, masks, etc

 CBRemodelingView
•
 Parent object of the Cambrian Home Augmentation SDK Responsibilities:
•
Lifecycle
• • •
Maintaining state
Setting tool modes for interaction
CBRemodelingScene
•
 Container for all information about current image or video being edited Responsibilities:
•
Initialization of image/video to be edited
• • • •
Storing and modifying assets (paints, floors, furniture, etc) Saving a fully-editable image that can be loaded later Storing and modifying lighting and color temperature

 CBRemodelingPaint
•
•
 Paint-specific asset object
A mutable container for paint data, allowing hot-swapping of any paint information while maintaining existing masks, in still or video
•
Color
Transparency (For stains) Sheen (Gloss level)
Values:
• • • •
UserData - for storing any value within the asset, typically ID’s or history

 Initializing CBRemodelingView
• • •
•
•
  • •
•
Ensure camera permissions are available before starting video
Get CBRemodelingView instance from storyboard Set delegate for callbacks
Determine state view should initialize into based on variables set by segues or other methods
New image
Previously saved CBScene Live video
Parent class must implement CBRemodelingViewDelegate

 Add a paint (asset) to the scene
  Set selected asset
  Remove asset
  
 Set Tool Mode
•
None
Available Modes
  Capture video into image
• • • • • •
Fill
Unfill Paintbrush Eraser FindColor
  
 Handling undo and redo
 
 Saving to a CBImage
  
 CBColorFinderView
 •
•
•
•
Scans video or image for prominent colors
In video it constantly searches for new colors as the camera moves
Initialization of view, delegate, and image/video are identical to CBRemodelingView
Implement CBColorFinderDelegate
Delegate method colorsFound(_ results: [CBColorResult]) returns 5 colors every ~3 seconds
•
Contains UIColor and CGPoint, representing the view-space position that the color was found
•
•
Details on specific implementation, such as working with a DB, exist in the demo app
  
 CBColoring
 • •
Class for common color match and differentiation methods
Simplifies commonly used color algorithms, such as those used in match tools
 
 Cambrian Android SDK
Identical to iOS SDK in terms of most objects and interfaces. Relies on the same binary SDK rendering engine. Utilizes a GLSurfaceView as its primary interface and bitmaps instead of UIImage, Fully customizable in user interface..
Primary components
•View
•
•Scene
• •
•Asset
•
  Holds everything, manages state and lifecycle
Holds information about current image/video being edited Assets, lighting, masks, etc
Generic parent type for remodeling types. Paint, floor, furniture, etc

 Initializing CBRemodelingView
• • •
•
•
 • •
•
Ensure camera permissions are available before starting video
Add CBRemodelingView instance to layout Set listener for callbacks
Choose appropriate initialization method
New image
Previously saved CBScene Live video
Class must implement CBRemodelingViewListener

 Initializing CBRemodelingView CBRemodelingView Methods
•
• •
• •
 Add CBRemodelingView instance to layout
Select tool mode
Set listener for callbacks
Go live, still
Choose appropriate initialization method
•
New image
• •
•
Ensure camera permissions are available before starting video
capture current state to still mode
•
•
Previously saved CBScene Live video
Class must implement CBRemodelingViewListener

 Initializing CBRemodelingView CBRemodelingVSVicienweMethods Continued
•
•
• •
•
• •
   • • • • •
Start and stop running AR Clear all results
Pause and resume capture Set undo and redo limits Undo and Redo changes
• •
•
Ensure camera permissions are available before starting video
Add CBRemodelingView instance to layout
Select tool mode
Set listener for callbacks
Initialize with images or existing scenes
Go live, still
Choose appropriate initialization method Obtain paint or flooring assets
•
New image
capture current state to still mode
•
•
Previously saved CBScene Live video
Class must implement CBRemodelingViewListener

 Initializing CBRemodelingView CBRemodelingSVicewneMectothnhotidsnsueCodntinued
•
•
• •
•
• •
   • • • • •
Start and stop running AR Clear all results
Pause and resume capture Set undo and redo limits Undo and Redo changes
• •
•
Ensure camera permissions are available before starting video
Add CBRemodelingView instance to layout
Select tool mode
Set listener for callbacks
Attach information to a scene for later lookup
Go live, still
Choose appropriate initialization method Adjust lighting
•
New image
capture current state to still mode
•
•
Previously saved CBScene Live video
Class must implement CBRemodelingViewListener

 Initializing CBRemodelingView CBRemodelingVSicewneMecothnhtodidsnueCdontinued
• StartandstoprunningAR • Clear all results
• Pause and resume capture • Set undo and redo limits
• Undo and Redo changes
• Add CBRemodelingView instance to layout
• SReltericetvteooBlemfordeeand after Image information • Set listener for callbacks
• SGaovleivea,nsdtilloladAssets
• Choose appropriate initialization method
•
• •
•
cRaepmtuorveecPuarriennt tCsotalotersto still mode • New image
• Previously saved CBScene
Live video
Ensure camera permissions are available before starting video Class must implement CBRemodelingViewListener

 Cambrian Web SDK
Fully compatible with iOS and android SDK’s and utilizes the same rendering engine. Projects generated by mobile devices may be loaded with the web system, and vice-versa. The API requires only a basic javascript interface and will communicate with a scalable binary, such as AWS or Azure, for computer vision.
 Web initialization
  
 Web API calls
 
