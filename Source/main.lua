gfx = playdate.graphics

import 'CoreLibs/object'

local hourHand <const> = playdate.geometry.lineSegment.new(0, 0, 0, 50)
local minuteHand <const> = playdate.geometry.lineSegment.new(0, 0, 0, 100)
local secondHand <const> = playdate.geometry.lineSegment.new(0, 0, 0, 100)

local clockColor = gfx.kColorWhite

local checkmarkMenuItem, error = playdate.getSystemMenu():addCheckmarkMenuItem("XOR", false, function(checked)
    clockColor = checked and gfx.kColorXOR or gfx.kColorWhite
end)

function playdate:update()
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, 400, 240)
	gfx.setColor(clockColor)

	playdate.drawFPS(0, 0)

	local time = playdate.getTime()

	local ms = time.hour*60*60*1000 + time.minute*60*1000 + time.second*1000 + time.millisecond

	drawClock(ms, playdate.geometry.point.new(200, 120), 180, 3)

end

function drawClock(ms, center, angle, depth, noHour)
	if depth < 0 then return end

	local centerAffine <const> = playdate.geometry.affineTransform.new()
	centerAffine:rotate(angle)
	centerAffine:translate(center.x, center.y)

	local hourAffine = centerAffine:copy()
	hourAffine:rotate(ms/1000/60/60/12 * 360, center.x, center.y)
	local minuteAffine = centerAffine:copy()
	minuteAffine:rotate(ms/1000/60/60 * 360, center.x, center.y)
	local secondAffine = centerAffine:copy()
	secondAffine:rotate(ms/1000/60 * 360, center.x, center.y)

	if not noHour then
		gfx.drawLine(hourAffine:transformedLineSegment(hourHand))
	end
	gfx.drawLine(minuteAffine:transformedLineSegment(minuteHand))
	gfx.drawLine(secondAffine:transformedLineSegment(secondHand))

	drawClock(ms, minuteAffine:transformedPoint(playdate.geometry.point.new(0, 100)), angle + (ms/1000/60/60 * 360) - (ms/1000/60/60/12 * 360) + 180, depth - 1, true)
	drawClock(ms, secondAffine:transformedPoint(playdate.geometry.point.new(0, 100)), angle + (ms/1000/60 * 360) - (ms/1000/60/60/12 * 360) + 180, depth - 1, true)
end
