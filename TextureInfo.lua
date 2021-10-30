local _G = _G

_G.HCTextureInfo = {}

HCTextureInfo = _G.HCTextureInfo

-- [ Add dictionaries below to add texture metadata ] --
-- @param Str             Path to texture 
-- @param OffsetX_0       How many pts to offset left side of texture
-- @param OffsetX_1       How many pts to offset right side of texture
-- @param OffsetY_0       How many pts to offset top side of texture
-- @param OffsetY_1       How many pts to offset bottom side of texture
-- @param LevelOffsetX    How many pts to offset the level text horizontally
-- @param LevelOffsetY    How many pts to offset the level text vertically
-- @param TexCoords       Coordinates of texture
-- @param AnimationInfo   Metadata for spritemaps
 

-- Player frames --
HCTextureInfo.PlayerFrame = {}
HCTextureInfo.PlayerFrame.blizzard = {
    Str = "Interface\\TargetingFrame\\UI-TargetingFrame.blp",
    OffsetX_0 = 0,
    OffsetX_1 = 0,
    OffsetY_0 = 0,
    OffsetY_1 = 0,
    LevelOffsetX = 0,
    LevelOffsetY = 0,
    RestIconOffsetX = 0,
    RestIconOffsetY = 0,
    TexCoords = {1, 0.09375, 0, .78125},
}
HCTextureInfo.PlayerFrame.hardcore = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder.blp",
    AccentStr = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_accent.blp",
    OffsetX_0 = 16,
    OffsetX_1 = 50,
    OffsetY_0 = 30,
    OffsetY_1 = -4,
    LevelOffsetX = -31,
    LevelOffsetY = -11,
    RestIconOffsetX = 1.5,
    RestIconOffsetY = 3,
    TexCoords = {0, 1, 0, 1},
}
HCTextureInfo.PlayerFrame.hardcore_animated = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_animated.blp",
    OffsetX_0 = 16,
    OffsetX_1 = 50,
    OffsetY_0 = 30,
    OffsetY_1 = -4,
    LevelOffsetX = -31,
    LevelOffsetY = -11,
    RestIconOffsetX = 1.5,
    RestIconOffsetY = 3,
    TexCoords = {0, 1, 0, 1},
    AnimationInfo =
	    {
		    TextureWidth = 1028,
		    TextureHeight = 256,
		    SpriteWidth = 257,
		    SpriteHeight = 128,
		    NumFrames = 8,
		    Throttle = .1,
	    }
}
-- Pet frames --
HCTextureInfo.PetFrame = {}
HCTextureInfo.PetFrame.blizzard = {
    Str = "Interface\\TargetingFrame\\UI-SmallTargetingFrame",
    AccentStr = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_accent.blp",
    OffsetX_0 = 0,
    OffsetX_1 = 1,
    OffsetY_0 = 0,
    OffsetY_1 = -9,
    LevelOffsetX = -31,
    LevelOffsetY = -11,
    RestIconOffsetX = 1.5,
    RestIconOffsetY = 3,
    TexCoords = {0, 1, 0, 1},
}
HCTextureInfo.PetFrame.hardcore = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder.blp",
    AccentStr = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_accent.blp",
    OffsetX_0 = -6,
    OffsetX_1 = 1,
    OffsetY_0 = 21,
    OffsetY_1 = -9,
    LevelOffsetX = -31,
    LevelOffsetY = -11,
    RestIconOffsetX = 1.5,
    RestIconOffsetY = 3,
    TexCoords = {0, .82, 0, .82},
}

-- Target frames --
HCTextureInfo.TargetFrame = {}
HCTextureInfo.TargetFrame.hardcore = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder.blp",
    AccentStr = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_accent.blp",
    OffsetX_0 = -50,
    OffsetX_1 = -16,
    OffsetY_0 = 30,
    OffsetY_1 = -4,
    LevelOffsetX = -.8,
    LevelOffsetY = 1.2,
    RestIconOffsetX = 1.5,
    RestIconOffsetY = 3,
    TexCoords = {1, 0, 0, 1},
}

-- Minimap frames --
HCTextureInfo.MinimapFrame = {}
HCTextureInfo.MinimapFrame.blizzard = {
    Str = "Interface\\Minimap\\UI-Minimap-Border",
    OffsetX_0 = -65,
    OffsetX_1 = 0,
    OffsetY_0 = 33,
    OffsetY_1 = -25,
    LevelOffsetX = 0,
    LevelOffsetY = 0,
    RestIconOffsetX = 0,
    RestIconOffsetY = 0,
    TexCoords = {-.001, 1, -.001, 1},
}
HCTextureInfo.MinimapFrame.hardcore = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_minimap_placeholder.blp",
    AccentStr = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_accent.blp",
    OffsetX_0 = 35,
    OffsetX_1 = -10,
    OffsetY_0 = 0,
    OffsetY_1 = 45,
    LevelOffsetX = 0,
    LevelOffsetY = 0,
    RestIconOffsetX = 0,
    RestIconOffsetY = 0,
    TexCoords = {-.001, 1, -.001, 1},
}

HCTextureInfo.TestFrame = {}
HCTextureInfo.TestFrame.animated = {
    Str = "Interface\\AddOns\\Hardcore\\Textures\\hardcore_frame_placeholder_animated.blp",
    OffsetX_0 = 16,
    OffsetX_1 = 50,
    OffsetY_0 = 30,
    OffsetY_1 = -4,
    LevelOffsetX = -31,
    LevelOffsetY = -11,
    RestIconOffsetX = 1.5,
    RestIconOffsetY = 3,
    TexCoords = {0, 1, 0, 1},
    AnimationInfo =
	    {
		    TextureWidth = 1024,
		    TextureHeight = 1024,
		    SpriteWidth = 113.777,
		    SpriteHeight = 113.777,
		    NumFrames = 56,
		    Throttle = .05,
	    }
}
