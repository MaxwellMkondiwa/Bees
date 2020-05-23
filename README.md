## Bees
### This is the public code for the manuscript "Honey Bees, Almond, and colonies mortality: An Economic Simulation of the U.S. Pollination Market"

**Please download all files into one folder and open script.gms file. To execute the model, please comment out the undisred part and then execute script.gms**  <br>
<br>
**Note:**<br>
* **All of the files must be saved in the same folder in order to run the code properly.** <br>
* **GAMSIDE is highly recommended to use.** <br>
* **The GAMS license including NLPEC solver is required.** <br><br>

**The following is the brief description of each file** <br>
* *a0-Data.gms* : store the raw data and data source we used
* *a-DataGen.gms* : make the basic calculation and generate the restart file a1.g00
* *b-Model_MCP.gms* : Mixed Complementarity Problem (MCP) Model. Solving the MCP model can give MPEC model a good starting point
* *b-Model_MPEC.gms* : Mathematical Programming with Equilibrium Constraints (MPEC) Model. This is the key file for calibration. The file can calibrate the model to get the V and Honey matrix that minizing the sum of squred error of pollination revenue of all crops between simuated and observed, plus the squred error of honey revenue between simulated and observed
