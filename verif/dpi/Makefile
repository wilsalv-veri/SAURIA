# --- Makefile for sauria_dpi.so ---

# --- Variables ---

# Compiler and Flags
CC          = gcc
CFLAGS      = -shared -fPIC -Wall -Wextra
OUTPUT      = sauria_dpi.so

# Define Environment Variables (Assuming $SAURIA is set in your shell environment)
# NOTE: If $SAURIA is not set when you run 'make', you MUST uncomment and set it here.
# SAURIA      = /path/to/your/sauria/project

# Define DSim Include Path (This path is specific to your installation)
DSIM_INCLUDE = $(DSIM)/2025.1/include

# Include Paths
INCLUDE_DIRS = -I $(SOFTFLOAT)/source/include -I $(DSIM_INCLUDE)

# Source Files
SOURCES     = $(SAURIA)/verif/dpi/fp16_dpi.c $(SOFTFLOAT_BUILD)/softfloat.a

# --- Targets ---

.PHONY: all clean

# Default target: Compiles the shared library
all: $(OUTPUT)

# Target to create the shared library (.so file)
$(OUTPUT): $(SOURCES)
	@echo "--- Compiling and Linking Shared Library: $@ ---"
	$(CC) $(CFLAGS) -o $@ $(SOURCES) $(INCLUDE_DIRS)

# Target to remove the compiled shared library
clean:
	@echo "--- Cleaning project files ---"
	rm -f $(OUTPUT)

# --- End of Makefile ---