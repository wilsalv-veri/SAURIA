# Sauria Verification Environment Setup and Usage Guide
This document describes how to set up the simulation environment and run tests for the Sauria verification environment using the Altair DSIM simulator.

--- 

## 1. Download Altair DSIM Simulator
1. Create an Altair user account to gain access to Altair tools and software
   Registration Link:
   https://admin.altairone.com/register
2. Download the Altair DSIM Simulator from:
    https://altair.com/dsim 
3. Follow Altair's installation instructions to install DSIM on your system

---

## 2. Obtain Altair DSIM License
Altair offers 2 types of DSIM licenses:
- **Cloud-based license**
- **Local single-seat license**

During the development of this project, a **free local single-seat license** was used.
> **Note:**
> If using a cloud license, the environment variable `ALTAIR_LICENSE_PATH` must be set instead of `DSIM_LICENSE`.

Steps to obtain a license
1. Login to the Altair DSim Cloud using your Altair account:
   https://app.metricsvcloud.com/
2. Navigate to the **licenses** section, under your profile
   https://app.metricsvcloud.com/security/licenses
3. Generate and download the license file

---

## 2. Initialize Repository Submodules
The Sauria RTL depends on source files tracked through Git submodules. These repositories must be initialized after cloning.

From the Sauria repository root, initialize and update all submodules:
   ```bash
   git submodule update --init --recursive
   ```
---

## 3. Set Env Variables
1. Open the following file using your preferred text editor:
   /verif/scripts/dsim_env.sh
2. Set the following environment variables
    - `DSIM_LICENSE` - Path to the DSIM license file
    - `DSIM`         - Path to DSIM installation 
    - `SAURIA`       - Path to the Sauria repository root

---

## 4. Source DSIM Environment
From the Sauria repository root directory, source the DSIM environment:
```bash 
source /verif/scripts/dsim_env.sh
```
---

## 5. Compile RTL, Testbench, and DPI Library
Before compiling, generate filelists for the target hardware version:

```bash
python3 verif/scripts/generate_filelists.py --hw-version int8_8x16
```

Other supported values are:
- `fp16_8x16`
- `int8_32x32`

If no hardware version is provided, `int8_8x16` is used by default:

```bash
python3 verif/scripts/generate_filelists.py
```

Compile the full environment using the provided helper script:
```bash
compile_sauria
```
---

## 6. Run Test
Run any test from the test list below using the following command:
```bash
run_sauria testname
```

To override default tensor data generation mode from the command line:
```bash
run_sauria testname IFMAPS_DATA_MODE=ALL_TWOS
run_sauria testname IFMAPS_DATA_MODE=6
```

