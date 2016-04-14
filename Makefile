# Compiler:
CC = g++-4.9

# Optimization:
CFLAGS = -O3

# Libs and Frameworks:
FRAMEWORKS = -lglew -lglfw3 -lAntTweakBar -lpng -framework Opengl -framework Cocoa -framework IOKit -framework CoreVideo -std=c++11

# Location for libs:
LIBFOLD = -L"/usr/local/lib"
# Location for includes:
INCFOLD = -I"/usr/local/include"

# Files:
FILES = $(wildcard src/*.cpp) $(wildcard shaders/*.cpp) $(wildcard src/utils/*.cpp) $(wildcard src/utils/*.c) 
EXTERNFILES = $(wildcard extern/OpenGL_Graphics_Engine/src/*.cpp) $(wildcard extern/OpenGL_Graphics_Engine/src/utils/*.cpp) $(wildcard extern/OpenGL_Graphics_Engine/src/utils/*.c)

# Binary folder:
BINFOLD = bin/

# Binary name:
BINNAME = Tessellation


all: compile
.PHONY: all

compile: $(FILES)
	$(CC) $(CFLAGS) $(EXTERNFILES) $(FILES)  -o $(BINFOLD)$(BINNAME) $(LIBFOLD) $(INCFOLD) $(FRAMEWORKS)
.PHONY: compile

run:
	./$(BINFOLD)$(BINNAME)
.PHONY: run

clean:
	rm -f $(BINFOLD)*
.PHONY: clean

sense: room1 clean all room2 run

room1:
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo "=========== cleaning and compiling ==========="
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""

room2:
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo "================== running =================="
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""

make: 
	@say ”Nu du Martin har du allt skitit i det blå skåpet”