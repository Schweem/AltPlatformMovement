# Sidequest : Moving in place
### Small Godot 4 project, practicing skills and approaching common tasks from a different perspective. 
------
### Current Features
- Simple player controller
- Simple moving objects
- Simple 'Mario' style enemies
- Functional level and score UI
- Dictionary based dialouge system
- dictionary based speaker name color system
------
### Dev highlight reel
![image](https://github.com/Schweem/AltPlatformMovement/assets/63567335/13ff44a2-820b-41f6-8caa-1644a065deec)
- Tilesets, improved visuals
- Some collision bugs 
------
![image](https://github.com/Schweem/AltPlatformMovement/assets/63567335/68fb3354-5eda-457d-b81f-dd7a5c3dcce6)
- Enhanced dialouge
  - Speaker names are stored in a dictionary with an assigned color
    - Colors are persistent across conversations, new colors only assigned to new characters 
  - Simple NPCs added, each have their own dialouge dictionary that is sent to UI via signal  
------
![image](https://github.com/Schweem/AltPlatformMovement/assets/63567335/ed1f9eb4-d94f-42ff-920a-01a823267e10)
- Dialouge bones
  - Dictionary based, dialouge : speaker string pairs. key is passed to the body text and value is passed to speaker text
  - Each 'conversation' is a dictionary, different dictionaries can be passed to a speak() method to play a conversation
------
![image](https://github.com/Schweem/AltPlatformMovement/assets/63567335/5b7872b8-453d-4ec2-8e3d-0bf694141cf6)
- Addition of simple UI and player graphics
  - Player sprite
  - 'World / Level' tracker, works just isnt updated in current gameplay
  - Score from stomping enemies  
------
![image](https://github.com/Schweem/AltPlatformMovement/assets/63567335/e6a5330b-715b-4be8-bc10-1fabe60d9f39)
- Initial stages, building collisions out of raycasting
- All directions of collisions are now handled by raycasts.
  - ![image](https://github.com/Schweem/AltPlatformMovement/assets/63567335/afb48af3-d63b-4e50-a51e-a17d8853805a)

