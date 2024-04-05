local gfx = playdate.graphics

local clockColor = gfx.kColorWhite
playdate.getSystemMenu():addCheckmarkMenuItem("XOR", false, function(checked)
    clockColor = checked and gfx.kColorXOR or gfx.kColorWhite
end)

local thickness = false
playdate.getSystemMenu():addCheckmarkMenuItem("thickness", false, function(checked)
    thickness = checked
end)

local ms = 0
local depth = 5
local shrinkage = 1

gfx.setLineCapStyle(playdate.graphics.kLineCapStyleRound)

function playdate:update()
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, 400, 240)
	gfx.setColor(clockColor)

	local time = playdate.getTime()
	if (playdate.isCrankDocked()) then
		ms += (time.hour*60*60*1000 + time.minute*60*1000 + time.second*1000 + time.millisecond - ms)/2
	else
		ms += playdate.getCrankChange()*100
	end

	if (playdate.buttonJustPressed(playdate.kButtonUp)) then
		depth += 1
	elseif (playdate.buttonJustPressed(playdate.kButtonDown)) then
		depth -= 1
	elseif (playdate.buttonJustPressed(playdate.kButtonLeft)) then
		shrinkage -= 0.1
	elseif (playdate.buttonJustPressed(playdate.kButtonRight)) then
		shrinkage += 0.1
	end

	drawClock(ms, 200, 120, -math.pi/2, 100, depth, true)

end

function drawClock(ms, x, y, angle, length, depth, drawHour)
	if depth < 0 then return end

	local hourAngle = angle + ms/1000/60/60/12 * 2*math.pi
	local minuteAngle = angle + ms/1000/60/60 * 2*math.pi
	local secondAngle = angle + ms/1000/60 * 2*math.pi

	local hx, hy = x + math.cos(hourAngle)*length/2, y + math.sin(hourAngle)*length/2
	local mx, my = x + math.cos(minuteAngle)*length, y + math.sin(minuteAngle)*length
	local sx, sy = x + math.cos(secondAngle)*length, y + math.sin(secondAngle)*length

	if thickness then
		gfx.setLineWidth(depth + 1)
	end

	if drawHour then
		gfx.drawLine(x, y, hx, hy)
	end
	gfx.drawLine(x, y, mx, my)
	gfx.drawLine(x, y, sx, sy)

	drawClock(ms, mx, my, minuteAngle - (hourAngle - angle) - math.pi, length*shrinkage, depth - 1)
	drawClock(ms, sx, sy, secondAngle - (hourAngle - angle) - math.pi, length*shrinkage, depth - 1)
end
