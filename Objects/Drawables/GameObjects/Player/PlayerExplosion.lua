local PlayerExplosion = GameObject:extend()

--the new function is its constructor but it does not run automatically :(
function PlayerExplosion:new(area,x,y,opts)
	Player.super.new(self,area,x,y,opts)
	--used to identify the object when deciding the draw order
	self.order = 70
	self.type = "PlayerExplosion"
	self.area = area
	self.dead = false
	self.x,self.y=x,y

	self.colour = opts.colour or ripeOrangeColour
    self.rotation = opts.rotation or love.math.random(0, 2*math.pi)
    self.size = opts.size or love.math.random(2, 3)
    self.velocity = opts.velocity or love.math.random(75, 150)
    self.lineWidth = opts.lineWidth or 2
  
    --collider for velocity
    self.collider = self.area.world:newCircleCollider(self.x,self.y,1)
	--self.collider = self.area.world:newLineCollider(self.x - self.size, self.y, self.x + self.size, self.y)
	self.collider:setObject(self)
	self.collider:setLinearVelocity(self.velocity*math.cos(self.rotation), self.velocity*math.sin(self.rotation))
	

	--tweening and killing the object
    self.timer:tween(opts.tweenTime or love.math.random(0.3, 0.5), self, {size = 0, velocity = 0, lineWidth = 0}, 
    				'linear',function() self.dead = true end)
	

end


function PlayerExplosion:update(dt)
	 PlayerExplosion.super.update(self,dt)
	 
end


function PlayerExplosion:draw()

	localRotation(self.x, self.y, self.rotation)
    love.graphics.setLineWidth(self.lineWidth)
    love.graphics.setColor(self.colour)
    love.graphics.line(self.x - self.size , self.y, self.x+self.size , self.y)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
    love.graphics.pop()
end


function PlayerExplosion:trash()
    PlayerExplosion.super.trash(self)
end

function localRotation(xLocation,yLocation,rotation)
	love.graphics.push()
	love.graphics.translate(xLocation,yLocation)
	love.graphics.rotate(rotation or 0)
	love.graphics.translate(-xLocation, -yLocation)
end

return PlayerExplosion
