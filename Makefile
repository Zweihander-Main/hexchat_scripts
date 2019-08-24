install:
	rm -rf ./ignoreTextEvents/build/*
	lua pack.lua ./ignoreTextEvents/src/ignoreTextEvents.lua
	mv ignoreTextEvents.bundle.lua ./ignoreTextEvents/build/ignoreTextEvents.lua
