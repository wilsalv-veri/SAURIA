import os 
import argparse

PROJECT_NAME = "SAURIA"
generate_filelist_path = os.path.abspath(__file__)
scripts_dir = os.path.dirname(generate_filelist_path)
project_path = os.getenv(PROJECT_NAME)
if project_path is None:
    project_path = os.path.abspath(os.path.join(scripts_dir, "../.."))

project_env_var = f"${PROJECT_NAME}"
VERIF_FILELISTS_DIR = f"{project_path}/verif/filelists"
DVT_FILELISTS_DIR = f"{project_path}/.dvt/filelists"

DEFAULT_HW_VERSION = "int8_8x16"
HW_VERSION_FILES = {
    "int8_8x16": "int8_8x16.svh",
    "fp16_8x16": "FP16_8x16.svh",
    "int8_32x32": "int8_32x32.svh",
}

def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate simulation filelists for SAURIA"
    )
    parser.add_argument(
        "--hw-version",
        choices=tuple(HW_VERSION_FILES.keys()),
        default=DEFAULT_HW_VERSION,
        help="Hardware configuration to include in hw_version_filelist.f",
    )
    return parser.parse_args()

def generate_hw_version_filelist_lines(hw_version):
    hw_file = HW_VERSION_FILES[hw_version]
    return [
        "buildconfig\n\n",
        f"${{RTL_DIR}}/hw_versions/{hw_file}\n",
    ]

def generate_filelist(file_name, lines, filelists_directory):
    abs_path_file_name = f"{filelists_directory}/{file_name}"
    print(f"ABS_PATH_FILE_NAME:{abs_path_file_name}")
    with open(abs_path_file_name, 'w') as f:
        for line in lines:
            f.write(line)

def generate_top_filelist_lines(filelist_names, dvt_mode=False):
    top_level_lines = []
    if dvt_mode:
        top_level_lines.append("// Set the include path for UVM macros and other files\n")
        top_level_lines.append("-uvm\n\n")
    else:
        top_level_lines.append("// Set the include path for UVM macros and other files\n")
        top_level_lines.append("+incdir+$UVM_HOME/src\n\n")
        top_level_lines.append("// Add the UVM package file. It is crucial to compile this before any\n")
        top_level_lines.append("// files that depend on it\n")
        top_level_lines.append("$UVM_HOME/src/uvm_pkg.sv\n\n")
    
    top_level_lines.append("\n\n//Reference other filelists\n")
    
    for filelist_name in filelist_names:
        if dvt_mode:
            top_level_lines.append(f"-f .dvt/filelists/dvt_{filelist_name}\n")
        else:
            top_level_lines.append(f"-f {project_env_var}/verif/filelists/{filelist_name}\n")

    return top_level_lines

def convert_lines_for_dvt(lines):
    converted_lines = []
    prefix = f"{project_env_var}/"

    for line in lines:
        converted_lines.append(line.replace(prefix, ""))

    return converted_lines

def addLinesUnderCurrentDirectory(cwd_path,include_files):
        
        supported_formats = ["vh","svh","sv","v", "dir"]
        cwd = get_current_dir_name(cwd_path)

        entries = []
        file_entries = [entry for entry in os.listdir(cwd_path) if os.path.isfile(os.path.join(cwd_path, entry))]
        dir_entries = [entry for entry in os.listdir(cwd_path) if os.path.isdir(os.path.join(cwd_path, entry))]
        
        if cwd == "tb":
            sort_by_match(dir_entries, "packages")
            sort_by_match(dir_entries, "reg_models")   
            sort_by_match(dir_entries, "interfaces")   
        
        elif cwd == "configuration":
            sort_by_match(file_entries, "cfg_pkg")
            sort_by_match(file_entries, "cfg_macros")
        elif cwd == 'packages':
            sort_by_match(file_entries, "tb_top")
            sort_by_match(file_entries, "tests")  
            sort_by_match(file_entries, "base_tests")
            sort_by_match(file_entries, "sauria_cfg_seqs")    
            sort_by_match(file_entries, "base_cfg_seqs")  
            sort_by_match(file_entries, "env")  
            sort_by_match(file_entries, "scbd")  
            sort_by_match(file_entries, "inv_feeders")  
            sort_by_match(file_entries, "golden_models")  
            sort_by_match(file_entries, "cfg_regs")  
            sort_by_match(file_entries, "common")  
        elif cwd == 'interfaces':
            sort_by_match(file_entries, "axi")
            sort_by_match(file_entries, "subsystem")
            sort_by_match(file_entries, "df_controller")
        
        entries.extend(file_entries)
        entries.extend(dir_entries)

        for entry in entries:
            
            abs_path = os.path.join(cwd_path, entry)
            directory = os.path.isdir(abs_path)
            path = abs_path.replace(entry,"")
  
            if not len(entry):
                continue
            
           
            include_files_under_directories = ["configuration","assertions","coverage","interfaces","packages", "tb"]
            includeLine = filelistIncludeLine(entry, path, directory)

            if (cwd == 'configuration') and ("macros" in entry):
                include_files.append("\n//DV Configuration Macros\n")
                with open(f"{abs_path}", "r") as file:
                    for macro in file:
                        include_files.append(f"+define+{macro.replace('\n','')}\n")
                include_files.append(f"\n")
            
            elif directory or (cwd in include_files_under_directories):
                includeLine.add_filename_line(include_files)
            
            if directory:
                addLinesUnderCurrentDirectory(abs_path, include_files)
                include_files.append("")


        if cwd == "tb":
            sort_by_match(include_files, "tb_top.sv", False)
        elif cwd == "packages":
            sort_by_match(include_files, "common_pkg")
        

def get_current_dir_name(dir_name):
    
    if "/" in dir_name:
        dir_name = dir_name.split("/")[-1]
    
    return dir_name

def sort_by_match(file_entries, match_string=".vh", inc_order=True):

    copy_entries = file_entries.copy()
    insert_idx_dict = {True:0,False:-1}
    inserted_new_line = False

    for idx, entry in enumerate(copy_entries):
        if match_string in entry:
            file_entries.pop(idx)
            file_entries.insert(insert_idx_dict[inc_order],entry)
        
class filelistIncludeLine:

    def __init__(self, name, abs_path="",directory=False ):
        self.header = ""
        self.name = name
        self.abs_path = abs_path
        self.rel_path = None
        self.rel_path_set = False
        self.set_rel_path()
        self.directory = directory
        
    def add_filename_line(self, lineList):
        filePath = f"{self.rel_path}{self.name}"

        line = [filePath + "\n",f"+incdir+{filePath}/\n"][int(self.directory)] 
        lineList.append(line)

    def add_line(self, lineList):
        filePath = f"{self.rel_path}{self.name}"

        line = [filePath + "\n",f"+incdir+{filePath}/\n"][int(self.directory)] 
        lineList.append(line)
        
    
    def set_rel_path(self):
        
        if not self.rel_path_set:
            project_dir = "SAURIA"
            project_dir_indx = self.abs_path.index(project_dir)
            self.rel_path = self.abs_path.replace( self.abs_path[0:project_dir_indx + len(project_dir)],project_env_var)
            self.rel_path_set = True

if __name__ == "__main__":

    args = parse_args()

    os.makedirs(VERIF_FILELISTS_DIR, exist_ok=True)
    os.makedirs(DVT_FILELISTS_DIR, exist_ok=True)

    hw_version_lines = generate_hw_version_filelist_lines(args.hw_version)
    generate_filelist("hw_version_filelist.f", hw_version_lines, VERIF_FILELISTS_DIR)

    dvt_hw_version_lines = convert_lines_for_dvt(hw_version_lines)
    generate_filelist("dvt_hw_version_filelist.f", dvt_hw_version_lines, DVT_FILELISTS_DIR)
    
    cfg_path = f"{project_path}/configuration"    
    tests_path = f"{project_path}/tests"    
    tb_path    = f"{project_path}/tb"

    paths = [cfg_path, tests_path, tb_path]
    filelist_names = []
     
    filelist_names.append("hw_version_filelist.f")
    filelist_names.append("configuration_filelist.f")
    filelist_names.append("rtl_filelist.f")
    
    for path in paths:
        include_files = []

        dir_name = path[ path.index(project_path) + len(project_path) + 1:]
        dir_name = get_current_dir_name(dir_name)
        
        includeLine = filelistIncludeLine(dir_name, path.replace(dir_name,""), True)
        includeLine.add_filename_line(include_files)    
        
        addLinesUnderCurrentDirectory(path,include_files)
        filelist_name = f"{dir_name}_filelist.f"
        
        if dir_name != "configuration":
            filelist_names.append(filelist_name)
        
        generate_filelist(filelist_name, include_files, VERIF_FILELISTS_DIR)

        dvt_filelist_name = f"dvt_{filelist_name}"
        dvt_include_files = convert_lines_for_dvt(include_files)
        generate_filelist(dvt_filelist_name, dvt_include_files, DVT_FILELISTS_DIR)

    
    top_filelist_lines = generate_top_filelist_lines(filelist_names)
    generate_filelist("top_filelist.f", top_filelist_lines, VERIF_FILELISTS_DIR)

    dvt_top_filelist_lines = generate_top_filelist_lines(filelist_names, dvt_mode=True)
    generate_filelist("dvt_top_filelist.f", dvt_top_filelist_lines, DVT_FILELISTS_DIR)