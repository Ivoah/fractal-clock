#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

#include "pd_api.h"

static PlaydateAPI* pd = NULL;

static int tzOff;

static double t0;

static unsigned int ms = 0;
static int depth = 5;
static double shrinkage = 1;

static LCDFont* font;

PDMenuItem* statsMenuItem;

static void drawClock(unsigned int ms, double x, double y, double angle, int length, int depth, bool drawHour) {
	if (depth < 0) return;

	double hourAngle = angle + ms/1000.0/60/60/12 * 2*M_PI;
	double minuteAngle = angle + ms/1000.0/60/60 * 2*M_PI;
	double secondAngle = angle + ms/1000.0/60 * 2*M_PI;

	double hx = x + cos(hourAngle)*length/2.0;
	double hy = y + sin(hourAngle)*length/2.0;

	double mx = x + cos(minuteAngle)*length;
	double my = y + sin(minuteAngle)*length;

	double sx = x + cos(secondAngle)*length;
	double sy = y + sin(secondAngle)*length;

	if (drawHour) pd->graphics->drawLine(x, y, hx, hy, 1, kColorWhite);
	pd->graphics->drawLine(x, y, mx, my, 1, kColorWhite);
	pd->graphics->drawLine(x, y, sx, sy, 1, kColorWhite);

	drawClock(ms, mx, my, minuteAngle - (hourAngle - angle) - M_PI, length*shrinkage, depth - 1, false);
	drawClock(ms, sx, sy, secondAngle - (hourAngle - angle) - M_PI, length*shrinkage, depth - 1, false);
}

static int update(void* ud) {
	pd->graphics->clear(kColorBlack);


	unsigned int milliseconds;
	int epoch = pd->system->getSecondsSinceEpoch(&milliseconds) + tzOff;
	struct PDDateTime time;
	pd->system->convertEpochToDateTime(epoch, &time);
	if (pd->system->isCrankDocked()) {
		ms += (time.hour*60*60*1000 + time.minute*60*1000 + time.second*1000 + milliseconds - ms)/2;
	} else {
		ms += pd->system->getCrankChange()*100;
	}

	PDButtons pushed;
	pd->system->getButtonState(NULL, &pushed, NULL);
	if (pushed & kButtonUp) {
		depth += 1;
	} else if (pushed & kButtonDown) {
		depth -= 1;
	} else if (pushed & kButtonLeft) {
		shrinkage -= 0.1;
	} else if (pushed & kButtonRight) {
		shrinkage += 0.1;
	}

	drawClock(ms, 200, 120, -M_PI_2, 100, depth, true);


	if (pd->system->getMenuItemValue(statsMenuItem)) {
		double t1 = pd->system->getElapsedTime();

		pd->system->convertEpochToDateTime(ms/1000, &time);
		char info[64];
		int len = sprintf(info, "%02d:%02d:%02d\nFPS: %2.1f\nDepth: %d\nLength: %0.1f", time.hour, time.minute, time.second, 1/(t1-t0), depth, shrinkage);
		// pd->system->logToConsole("%d", len);
		pd->graphics->drawText(info, len, kASCIIEncoding, 0, 0);
		
		t0 = t1;
	}
	return 1;
}

#ifdef _WINDLL
__declspec(dllexport)
#endif
int eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg) {
	if (event == kEventInit) {
		pd = playdate;

		pd->display->setRefreshRate(0); // run as fast as possible
		pd->graphics->setDrawMode(kDrawModeNXOR);
		tzOff = pd->system->getTimezoneOffset();
		font = pd->graphics->loadFont("Nontendo-Bold", NULL);
		pd->graphics->setFont(font);

		statsMenuItem = pd->system->addCheckmarkMenuItem("Show stats", 1, NULL, NULL);

		pd->system->setUpdateCallback(update, NULL);
	}
	
	return 0;
}
