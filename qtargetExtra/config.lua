Config = {}

Config.Healing = 0 -- // If this is 0, then its disabled.. Default: 3.. That means, if a person lies in a bed, then he will get 1 health every 3 seconds.

Config.objects = {
	SitAnimation = {anim='PROP_HUMAN_SEAT_CHAIR_MP_PLAYER'},
	BedBackAnimation = {dict='anim@gangops@morgue@table@', anim='ko_front'},
	BedStomachAnimation = {anim='WORLD_HUMAN_SUNBATHE'},
	BedSitAnimation = {anim='WORLD_HUMAN_PICNIC'},
	locations = {
		[2117668672] = {object=2117668672, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=-1.4, direction=0.0, bed=true},
		[1631638868] = {object=1631638868, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=-1.4, direction=0.0, bed=true},
		[-1519439119] = {object=-1519439119, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=-2.0, direction=0.0, bed=true},
		[-171943901] = {object=-171943901, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=-0.0, direction=168.0, bed=false},
		[1268458364] = {object=1268458364, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=-0.4, direction=168.0, bed=false},
		[96868307] = {object=96868307, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=-0.4, direction=168.0, bed=false},
		[1037469683] = {object=1037469683, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=-0.4, direction=168.0, bed=false},
		[867556671] = {object=867556671, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=-0.4, direction=168.0, bed=false},
		[-377849416] = {object=-377849416, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=-0.4, direction=168.0, bed=false},
		[-109356459] = {object=-109356459, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=-0.4, direction=168.0, bed=false},
		[-1091386327] = {object=-1091386327, verticalOffsetX=0.0, verticalOffsetY=0.13, verticalOffsetZ=-0.2, direction=90.0, bed=false},
		[536071214] = {object=536071214, verticalOffsetX=0.0, verticalOffsetY=-0.1, verticalOffsetZ=-0.5, direction=180.0, bed=false},
		[538002882] = {object=538002882, verticalOffsetX=0.0, verticalOffsetY=0.0, verticalOffsetZ=0.1, direction=168.0, bed=false},
		[-1118419705] = {object=-1118419705, verticalOffsetX=0.0, verticalOffsetY=-0.1, verticalOffsetZ=-0.5, direction=168.0, bed=false},
		[-992710074] = {object=-992710074, verticalOffsetX=0.0, verticalOffsetY=-0.1, verticalOffsetZ=-0.7, direction=168.0, bed=false},
		[-1195678770] = {object=-1195678770, verticalOffsetX=0.0, verticalOffsetY=-0.1, verticalOffsetZ=-0.7, direction=5.0, bed=false},
		[-992735415] = {object=-992735415, verticalOffsetX=0.0, verticalOffsetY=-0.0, verticalOffsetZ=0.1, direction=180.0, bed=false},
		[-1761659350] = {object=-1761659350, verticalOffsetX=0.0, verticalOffsetY=-0.0, verticalOffsetZ=-0.5, direction=180.0, bed=false},
		[-1626066319] = {object=-1626066319, verticalOffsetX=0.0, verticalOffsetY=-0.0, verticalOffsetZ=0.1, direction=180.0, bed=false}
		   }
                 }

Config.seats = {
	538002882, -- MRPD Chairs 
	-1118419705, -- MRPD Chairs 
	-992710074, -- Pillbox Stools
	-109356459, -- Chairs in Pillbox
	-992735415, -- Chair in Sandy Customs Office
	-1761659350, -- Vineyard Wood Chair
	-1626066319, -- Stumpys Office Chair
	-171943901, 
	1268458364, 
	96868307, 
	1037469683, 
	867556671, 
	-377849416, 
	-1091386327, 
	536071214, 
	-1195678770,
}

Config.beds = {
	1631638868, -- Hospital Beds 
	2117668672, -- Hospital Beds 
	-1519439119, -- MRI Machine Pillbox
}
