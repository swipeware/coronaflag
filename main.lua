-- main.lua
--
-- Ingemar Bergmark
-- www.swipeware.com
--
-- Created: 2013-11-02
--
-- Waving flag entry for Corona SDK Graphics 2.0 showcase/competition November 2013
--
-- Graphics 2.0 features used:
-- ---------------------------
-- o Snapshots
-- o Quadrilateral distortion 
-- o Image filter effects
--

display.setStatusBar(display.HiddenStatusBar);

local LOGO				= "coronalogo.png";
local LOGO_WIDTH		= 800;
local LOGO_HEIGHT		= 241;
local NUM_SLICES		= 128;
local MAX_AMPLITUDE		= 12;					-- max amplitude in px
local PERIOD_TIME		= 2000;					-- time for a full sine period
local NUM_WAVES			= 3.5;					-- number of waves in flag

local timeStep			= PERIOD_TIME * NUM_WAVES / NUM_SLICES;
local sliceWidth		= LOGO_WIDTH / NUM_SLICES;
local logoSlice			= {};					-- table for logo slices
local storedTime		= system.getTimer();	-- used for inter-frame time calculation
local loopT             = 0;                    -- used to time slice updates
local deltaT            = 0;                    -- used to time slice updates

-- utility functions
local sin = math.sin;
local pi  = math.pi;

local showSlice = function(i)
	logoSlice[i].y = sin(pi * 2 * (logoSlice[i].timePos / PERIOD_TIME)) * 
				logoSlice[i].amplitude + display.contentCenterY;
	
	if (i > 1) then
		local yDiff = logoSlice[i].y - logoSlice[i - 1].y;	

		-- quadrilateral distortion of slice
		logoSlice[i].path.y1 = -yDiff;
		logoSlice[i].path.y2 = -yDiff;
		
		-- add shine/shadow effect
		logoSlice[i].fill.effect.exposure = -yDiff * 0.2;
	end
end

-- divide Corona logo into slices ----------------------------------------------
local sheetOptions = {
    width = LOGO_WIDTH,
    height = LOGO_HEIGHT,
    numFrames = 1
}

local logoSheet = graphics.newImageSheet(LOGO, sheetOptions);

for i = 1, NUM_SLICES do
	local sliceStart = (i - 1) * sliceWidth + sliceWidth / 2;	
	
	local logo = display.newImage(logoSheet, 1);	
	logo.anchorX = 0;
	logo.x, logo.y = -sliceStart, 0;
	
	logoSlice[i] = display.newSnapshot(sliceWidth, LOGO_HEIGHT);
	logoSlice[i].anchorX = 0;
	logoSlice[i].group:insert(logo);
	logoSlice[i].amplitude = i / (NUM_SLICES / MAX_AMPLITUDE);
	logoSlice[i].timePos = -(i * timeStep); 
	logoSlice[i].x = (display.contentWidth - LOGO_WIDTH) / 2 + (i - 1) * sliceWidth;
	logoSlice[i].fill.effect = "filter.exposure";
	
	showSlice(i);	
end

-- animate flag ----------------------------------------------------------------
local onEnterFrame = function(event)
	local currentTime = system.getTimer();
	local timeDelta = currentTime - storedTime;
	
	for i = 1, NUM_SLICES do
		logoSlice[i].timePos = (logoSlice[i].timePos + timeDelta) % PERIOD_TIME;		
		showSlice(i);
	end
    
    ---------------------------------------------------
    -- calculate time needed for all slices to update
	deltaT = deltaT + (system.getTimer() - currentTime)
	loopT = loopT + 1;
    
	if (loopT % 60 == 0) then -- print results every second
		print(deltaT / 60)
		deltaT = 0;
	end
    --
	---------------------------------------------------
    
	storedTime = currentTime;
end

Runtime:addEventListener("enterFrame", onEnterFrame);
