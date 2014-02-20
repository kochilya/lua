-- Quary
x=0
y=0
z=0

function Start()
	i=0
	while i<2 do
		if turtle.detectDown() then
			turtle.digDown()
			turtle.down()
		end
	end
end