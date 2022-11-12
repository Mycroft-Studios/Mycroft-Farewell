# ped_spawner

![keeper](https://user-images.githubusercontent.com/14336807/112101162-71129b00-8b63-11eb-9778-eb0434d97a5c.png)
An easily configurable ped spawner for fivem servers.  Supports animations as well if you have the patience to find one you like.


Installation:<br>
* Place the file into the resources folder for your server.<br>
* Add 'ensure ped_spawner' to your server.cfg<br>
* Enjoy!<br>

Configuration Options:<br>
* Config.Invincible: Makes the peds invincible.<br>
* Config.Frozen: Makes the peds unable to move.<br>
* Config.Stoic: Makes the peds unaware of their surroundings.<br>
* Config.MinusOne: If you need to subtract 1 from your Z-Axis coordinates when you grab them, set this to true. If you set it to false, all the default peds need to be adjusted.<br>
* Config.Distance: The distance you want peds to be spawned/deleted at.
* Config.Fade: Allows peds to fade into/out of existence, rather than just popping in. The spawning process with this doesn't catch the eye as much.

Usage:<br>
* To add another ped, just add a new line to the end of the config.<br>
* <a href="https://docs.fivem.net/docs/game-references/ped-models/">The Ped Model names can be found here.</a><br>
* <a href="https://alexguirre.github.io/animations-list/">A list of animations can be found here.</a><br><br>

Below you can see an example of a code snippet you could use. Both the animDict and animName variables are completely optional.
```lua
  {
	  model = "s_m_y_xmech_02",
		coords = vector3(106.11213684082,6627.7666015625,31.787231445312), --PALETO BAY MECHANIC
		heading = 20.0, 
		gender = "male", 
		animDict = "missmechanic", 
		animName = "work_base",
  },
```

## [1.1.0] - 2021-03-23
 
### Added
* Deletion of peds when player gets far enough away
### Fixed
* Took some of the config variables out of tables.

## [1.2.0] - 2021-03-23
 
### Added
* Option to fadein/fadeout the peds<br>
![fade](https://user-images.githubusercontent.com/14336807/112215947-33068d00-8bde-11eb-86e1-bc3408d1afde.gif)

