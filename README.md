## Bees
### This is the public code for the manuscript "Honey Bees, Almond, and colonies mortality: An Economic Simulation of the U.S. Pollination Market"

**Please download all files into one folder and open Bee.gpr file if GAMSIDE is installed. To execute the model, please open script.gms  and comment out the undesired part by adding "*" as the first character in the line and then save and execute script.gms**  <br>
<br>
**Note:**<br>
* **All of the files must be saved in the same folder in order to run the code properly.** <br>
* **GAMSIDE is highly recommended .** <br>
* **A GAMS license including NLPEC solver is required.** <br><br>

**The following is the brief description of each file** <br>
* ************************************************ 
###Calibration files
* ***a0-Data.gms*** : stores the raw data and data source used
* ***a-DataGen.gms*** : makes basic calculations and generates the restart file a1.g00
* ***b-Model_MCP.gms*** : Mixed Complementarity Problem (MCP) Model. Solves the MCP model to give MPEC model a good starting point
* ***b-Model_MPEC.gms*** : Mathematical Programming with Equilibrium Constraints (MPEC) Model. This is the key file for calibration. The file can calibrate the model to get the V and Honey matrix that minimize the sum of squared errors of pollination revenue of all crops between simulated and observed, plus the squared error of honey revenue between simulated and observed
* ************************************************ 
###   Simulation files
* ***c-Almond.gms*** : Simulates the base Almond scenarios without forage scarcity adjustment
* ***c-Mortality.gms*** : Simulates the base Mortality scenarios without forage scarcity adjustment
* ***c-AlmondForage.gms*** : Simulates the base Almond scenarios with forage scarcity adjustment
* ***c-MortalityForage.gms*** : Simulates the base Almond scenarios with forage scarcity adjustment
* ************************************************ 
###   Auxiliary files
* ***script.gms*** : execution file for convenience. It introduces how to execute the files above
* ***c-Sim_No_forage.gms*** : Base Non-linear Programming (NLP) Model without forage scarcity adjustment. It is included in *c-Almond.gms* and *c-Moratlity.gms* files
* ***c-Sim_No_forage.gms*** : Base Non-linear Programming (NLP) Model with forage scarcity adjustment. It is included in *c-AlmondForage.gms* and *c-MoratlityForage.gms* files
* ***Bee.grp*** : GAMSIDE project file to provide the correct environment
* ***MPEC_2015_90.gdx*** : Our calibration result using 2015 data
* ***MPEC_2016_90.gdx*** : Our calibration result using 2016 data
