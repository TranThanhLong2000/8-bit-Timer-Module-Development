
VLID = vlib
VMAP = vmap
COMPILER = vlog -work $(WORK_LIB)
SIM = vsim -c
WORK_LIB = work
SIM_OPT = "run -all"


SRC_DIR = C:/Users/admin/Desktop/my_project
RTL_DIR = $(SRC_DIR)/rtl           
TB_DIR = $(SRC_DIR)/tb              


RTL_FILES := $(shell find $(RTL_DIR) -name "*.v") 
TB_FILE := $(shell find $(TB_DIR) -name "*.v")    


all: init compile simulation clean

init:
	$(VLID) $(WORK_LIB)
	$(VMAP) work $(WORK_LIB)

compile:
	@echo "RTL files: $(RTL_FILES)"
	@echo "Testbench file: $(TB_FILE)"
	$(COMPILER) $(RTL_FILES)   
	$(COMPILER) $(TB_FILE)     

simulation:
	$(SIM) $(WORK_LIB).tb_top_module -do $(SIM_OPT)   

clean:
	@rm -rf work transcript modelsim.ini output report.txt
