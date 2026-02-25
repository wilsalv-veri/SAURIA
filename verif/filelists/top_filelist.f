// Set the include path for UVM macros and other files
+incdir+$UVM_HOME/src

// Add the UVM package file. It is crucial to compile this before any
// files that depend on it
$UVM_HOME/src/uvm_pkg.sv



//Reference other filelists
-f $SAURIA/verif/filelists/hw_version_filelist.f
-f $SAURIA/verif/filelists/configuration_filelist.f
-f $SAURIA/verif/filelists/rtl_filelist.f
-f $SAURIA/verif/filelists/tests_filelist.f
-f $SAURIA/verif/filelists/tb_filelist.f
