.PHONY: clean
.PHONY: all
.PHONY: run

PLAYDATE_SDK_PATH="/Users/ivo/Developer/PlaydateSDK"
SIM="Playdate Simulator"

all: Fractal\ Clock.pdx

Fractal\ Clock.pdx: Source/main.lua
	pdc Source Fractal\ Clock.pdx

clean:
	rm -rf Fractal\ Clock.pdx

run: all
	$(PLAYDATE_SDK_PATH)/bin/$(SIM).app/Contents/MacOS/$(SIM) Fractal\ Clock.pdx

