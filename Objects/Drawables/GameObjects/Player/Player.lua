--GameObject = require "Objects/GameObjects/GameObject"
--if error "attempt to index global 'OBJ' (a nil value)" appears, check to make sure that alll the object calls are its own
local Player = GameObject:extend()

function Player:new(area,x,y,opts)
	Player.super.new(self,area,x,y,opts)
	----used to identify the object when deciding the draw order
	--not used anymore
	self.hp = self.area:addGameObject("HpBar",self.area.room.screenW/2-50,10)
	self.answer = self.area:addGameObject("Answer",self.x,self.y,{playerObject = self})
	self.hpAmount = 100
	self.order = 53
	self.type = "Player"
	self.dead = false
	self.x, self.y = x,y
	self.w, self.h = 10, 10
	self.points = 0
	self.sound = playerExplosion
	--Adding a new colider to the physics world inside of the area the player is in.
	self.collider = self.area.world:newCircleCollider(self.x,self.y,self.w)
	--attaching the physics collider to the player object
	--We can also use "getObject to "
	self.collider:setObject(self)
	self.collider:setCollisionClass("Player")
	--setGravity has x and y arguments
	--self.area.world:setGravity(0,512)
--MOVEMENT VARIABLES
	--In LÖVE angles work in a clockwise way, meaning math.pi/2 is down and -math.pi/2 is up (and 0 is right)
	self.rotation = -math.pi/2
	self.rotationVelocity = 1.77*math.pi
	self.currentVelocity = 0
	self.maxVelocity = 70
	self.acceleration = 20
--MOVEMENT VARIABLES
	timer:every(0.02,function() self:trail()end)
	--create the illusion of travelign thourgh space, WIP
	--timer:every(0.2,function()self.area:addGameObject("PlayerExplosion", 0,love.math.random(0,self.area.room.screenH),{tweenTime = 60})end)
	--timer:every(0.25,function() self:shoot() end)

end

function Player:update(dt)
	--we update the x and y value to match the values of the collider in the parent object
	--the bellow specifies to firstly run the update function of the parent object
	Player.super.update(self,dt)
	--the player dies when it moves off-screenb
    if self.hpAmount == 0 then
    	self.dead = true
    end
    if self.x < 0 then   self.dead = true end
    if self.y < 0 then   self.dead = true end
    if self.x > self.area.room.screenW then   self.dead = true end
    if self.y > self.area.room.screenH then   self.dead = true end


  	if self.collider then
  		 if self.collider:enter("Enemy") then
  		 	local collissionData = self.collider:getEnterCollisionData('Enemy')
    		local enemy = collissionData.collider:getObject()
    		local answer = tonumber(self.answer.answer)
    		if answer== enemy.equation.equation then 
    			enemy:damage(20)
    			--move this to the enemy obj later, behaviour belongs to that obj
    			self.area:addGameObject("TextFX",enemy.x,enemy.y,{colour = greenColour, text = "+CORRECT",direction = 7})
    			self:heal(10)
    			self.answer.answer = ""
    				self.points = self.points + enemy.equation.points
    		else
    			--move this to the enemy obj later
    			self.area:addGameObject("TextFX",enemy.x,enemy.y,{colour = redColour, text = "+WRONG", direction = -7})
    			self.answer.answer = ""
    			self:damage(10)
    			--only remove points if they are above 0/more than the points you are going to remove
    			if self.points >=  enemy.equation.points/2 then
    				self.points = self.points - enemy.equation.points/2
    			end
    		end
    		
    	end
    end

    

    --if input:pressed("die") then  self.dead = true end
	--change the rotation variable left or right, like old RC cars
	if input:down("left") then self.rotation = self.rotation - self.rotationVelocity*dt end
	if input:down("right") then self.rotation = self.rotation + self.rotationVelocity*dt end


	--Always get the minmimum of the two values, so max velocity is the cap
	self.currentVelocity = math.min(self.currentVelocity+self.acceleration*dt, self.maxVelocity)
	if self.collider then
		self.collider:setLinearVelocity(self.currentVelocity*math.cos(self.rotation),self.currentVelocity*math.sin(self.rotation))
	end

end

function Player:draw()
		
		--funny resoults if we change the x for the second point to +amount, almost gives off a fake 3d effect 
		--love.graphics.line(self.x,self.y,self.x+2*self.w*math.cos(self.rotation),self.y+2*self.w*math.sin(self.rotation))
		
		--[[INTERESTIGN EFFECT
			localRotation(self.x+1*self.w*math.cos(self.rotation),
						self.y+1*self.w*math.sin(self.rotation), math.pi/2)
		--]]

		love.graphics.line(self.x+1*self.w*math.cos(self.rotation),
							self.y+1*self.w*math.sin(self.rotation),
							self.x+1.3*self.w*math.cos(self.rotation),
							self.y+1.3*self.w*math.sin(self.rotation))
		--love.graphics.circle("fill", self.x, self.y,self.w-1)
		love.graphics.setColor(255, 255, 255)

		love.graphics.circle("fill", self.x, self.y,self.w)
		love.graphics.print("Score:"..self.points, 0,0)
		
		--[[ UNUSED 
		love.graphics.push()

		--rotating the movement reticle around in the player object
		
		love.graphics.translate(self.x, self.y)
		love.graphics.rotate(self.rotation)
			love.graphics.circle("line",self.x/6,self.y/,5)
		love.graphics.pop()
		--love.graphics.circle("line",self.x,self.y,self.x+2*self.w*math.cos(self.rotation),self.y+2*self.w*math.sin(self.rotation))
		--love.graphics.line(self.x,self.y,self.x+2*5*math.cos(self.rotation),self.y+2*5*math.sin(self.rotation))
		--]]
end
--Trashing the player when 

--temoporary not used on the player object, to be merged with the die() fucntion
function Player:trash()
	self.sound:play()
	Player.super.trash(self)
	
	for i = 1, love.math.random(8,12) do
    	self.area:addGameObject("PlayerExplosion", self.x, self.y,{colour = redColour})
    	camera:shake(5,0.5,60)
    end
end
--not used for now
function Player:shoot()

	self.area:addGameObject ("ProjectileFX",
								self.x+1.2*self.w*math.cos(self.rotation),
								self.y+1.2*self.w*math.sin(self.rotation),{playerObject = self})
end
function Player:trail()
	if self.dead ~= true then
		self.area:addGameObject("Trail",self.x,self.y,{radius=10})
	end
end

function Player:damage(amount)
	self.hpAmount = self.hpAmount-amount
	camera:flash(0.05,{200,0,0,150})
	self.hp:damage(amount)
end

function Player:heal(amount)
	if self.hpAmount<100 then
		camera:flash(0.05,{0,200,0,150})
		self.hpAmount = self.hpAmount+amount
		self.hp:heal(amount)
	end
end



--for now its easier and faster to copy this fucntion around rather than making my own library
function localRotation(xLocation,yLocation,rotation)
	love.graphics.push()
	love.graphics.translate(xLocation,yLocation)
	love.graphics.rotate(rotation or 0)
	love.graphics.translate(-xLocation, -yLocation)
end

--attempt at lerping function for smoothly transitioning the velocity of the object
--unused
function lerp(a,b,t)
	return (1-t)*a + t*b 
end
return Player