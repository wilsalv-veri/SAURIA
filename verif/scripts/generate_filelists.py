import os 

PROJECT_NAME = "SAURIA"
project_path = os.getenv(PROJECT_NAME)
project_env_var = f"${PROJECT_NAME}"

generate_filelist_path = os.path.abspath(__file__)
scripts_dir = os.path.dirname(generate_filelist_path)

def generate_filelist(file_name, lines):
    filelists_directory =  f"{project_path}/verif/filelists"
    abs_path_file_name = f"{filelists_directory}/{file_name}"   
    print(f"ABS_PATH_FILE_NAME:{abs_path_file_name}")
    with open(abs_path_file_name, 'w') as f:
        for line in lines:
            f.write(line)

def generate_top_filelist_lines(filelist_names):
    top_level_lines = []
    top_level_lines.append("// Set the include path for UVM macros and other files\n")
    top_level_lines.append("+incdir+$UVM_HOME/src\n\n")
    top_level_lines.append("// Add the UVM package file. It is crucial to compile this before any\n")
    top_level_lines.append("// files that depend on it\n")
    top_level_lines.append("$UVM_HOME/src/uvm_pkg.sv\n")
    
    
    top_level_lines.append("\n//Reference other filelists\n")
    
    for filelist_name in filelist_names:
        top_level_lines.append(f"-f {project_env_var}/verif/filelists/{filelist_name}\n")

    return top_level_lines

def addLinesUnderCurrentDirectory(cwd_path,include_files):
        
        supported_formats = ["vh","svh","sv","v", "dir"]
        cwd = get_current_dir_name(cwd_path)

        entries = []
        file_entries = [entry for entry in os.listdir(cwd_path) if os.path.isfile(os.path.join(cwd_path, entry))]
        dir_entries = [entry for entry in os.listdir(cwd_path) if os.path.isdir(os.path.join(cwd_path, entry))]
        
        if cwd == "tb":
            sort_by_match(dir_entries, "packages")
            sort_by_match(dir_entries, "interfaces")   
        elif cwd == 'packages':
            sort_by_match(file_entries, "tb_top")
            sort_by_match(file_entries, "tests")  
            sort_by_match(file_entries, "base_tests")  
            sort_by_match(file_entries, "env")  
            sort_by_match(file_entries, "scbd")  
            sort_by_match(file_entries, "golden_models")  
            sort_by_match(file_entries, "sauria_cfg_seqs")  
            sort_by_match(file_entries, "base_cfg_seqs")  
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
            
            include_files_under_directories = ["assertions","coverage","interfaces","packages", "tb"]
            includeLine = filelistIncludeLine(entry, path, directory)
          
            if directory or (cwd in include_files_under_directories):
                includeLine.add_line(include_files)
            
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
    
    tb_path    = f"{project_path}/tb"
    tests_path = f"{project_path}/tests"
    
    paths = [tests_path, tb_path]
    filelist_names = []
     
    filelist_names.append("hw_version_filelist.f")
    filelist_names.append("rtl_filelist.f")

    for path in paths:
        include_files = []

        dir_name = path[ path.index(project_path) + len(project_path) + 1:]
        dir_name = get_current_dir_name(dir_name)
        
        includeLine = filelistIncludeLine(dir_name, path.replace(dir_name,""), True)
        includeLine.add_line(include_files)    
        
        addLinesUnderCurrentDirectory(path,include_files)
        filelist_name = f"{dir_name}_filelist.f"
        filelist_names.append(filelist_name)
        generate_filelist(filelist_name, include_files)


    top_filelist_lines = generate_top_filelist_lines(filelist_names)
    generate_filelist("top_filelist.f",top_filelist_lines)