## Disclaimer

*This is an incomplete repo - I wouldn't necessarily recommend using it lol. There is alot of mess that needs cleaning up. (Lots of learning/experimenting took place during the making of the module 😅)*

It was fun making it and I do wish to finish it at some point, but I have other priorities for the moment. Feel free to fork it and make your own.

## What is it?
The module is designed to provide easy-to-use visual debugging functions, for resource developers. Allowing the developer to *add*, *update*, *toggle*, and *remove* debug features in a quick, simple and reusable way. The module utilizes the FiveM Draw Natives, and handles most of the tedious stuff related to the use of those natives. Natives such as `DrawRect` and `DrawLine`, as well as the numerous text commands related to `BeginTextCommandDisplayText` or similar.

## Origins
This module was first built, to assist our team in the development of a *police proximity sensor* resource. The tool, allowed me to see what the resource was doing just by recording footage and watching back frame-by-frame. Which also helped in visually explaining bugs to the other developers. The module was heavily inspired by earlier released development footage from another game.

## Footage

Here are some videos from development, showing it's practical use - in comparison to reading the console output. 

Necessary context:
  - 🔵**Blue:**  registered ped
  - 🟢**Green:** visualisation of raycasts - checking LOS to ped bones
  - 🔴**Red:**  ped in memory, but ignored for optimisation

*the RGB graph has nothing to do with the module, its just a netgraph I had open.*
    
https://github.com/user-attachments/assets/67c407a7-76b0-4d65-a3bc-b31855969d31



https://github.com/user-attachments/assets/79097434-63da-4c66-9b71-fe15244b4ff5

Here it shows each ped's ID, along with their dot product from the forward vector of the vehicle.

This was helpful in debugging an issue i had with faulty dot product results - the angles returned weren't accurate to the position of the ped. And I was able to see that, in 3d space. 

Context:
  - 🟡**Yellow:**  ped is in vision cone of sensor.
  - 🟠**Orange:**  ped is outside vision cone of sensor.

https://github.com/user-attachments/assets/95d85217-0f7b-4d5e-b696-15e9557d6616

Here is a feature I added to show events happening in 3d space.

Visualising the system changing its state, as the condition of the vehicle changes (speed, ignition, etc)

##### * volume warning *

https://github.com/user-attachments/assets/23a2e31b-5b6f-46da-91a8-f1ba132118ba

Here is the module, after quite alot of work.

The footage, *if not such low bitrate* would show you the information about each vehicle in proximity, changing in real time. I also added conditional values to allow for colourisation.

https://github.com/user-attachments/assets/03beb74c-e0df-4b06-bb16-31f6f24c95aa

Additionally, I have been working on a live variable editor. Of which to my knowledge, has never been done in fivem before.

I have proven it is possible with prototypes, but it isn't refined enough to add here.

It allows you to change variables in real time, via a chat commmand or a inspector menu (incomplete). 
This is similar to how you can expose variables to the inspector of game engines like unity.

This saves you from having to tab between applications to edit, re-ensure your resource or even restart your server - every time you *just* want to tweak a variable.


<!---
## I'm currently refactoring this module
With  the developer experience in mind. It will be solely a framework for developers to build off. 

In other words - You handle the values, the module handles the rendering.

It will allow you to build your own system to manage values. Which will allow for a large variety of use cases.

### Example:
#### Rendering ped bones
The module wont have a "RenderPedBones" Function - You get to create your own (utilizing the module line rendering), and plug it in to the module.
You can then toggle on (or off) that function in particular - whenever you would (or wouldn't) like to see the ped bones.
--->
