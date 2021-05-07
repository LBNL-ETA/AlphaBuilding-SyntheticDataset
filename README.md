# AlphaBuilding-SyntheticDataset

This repository is created for the AlphaBuilding-SyntheticDataset. Details about this dataset could be found on its [GitHub page](https://lbnl-eta.github.io/AlphaBuilding-SyntheticDataset/).

## Reproduce the Dataset
The source code to reproduce the dataset could be found in the code directory. Follow the steps below to reproduce the dataset:
1. Install [OpenStudio v2.9.1](https://github.com/NREL/OpenStudio/releases/tag/v2.9.1). 
Set up the full path of openstudio.rb in the [create_workflow.rb](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/code/create_workflow.rb#L23) script. 
The openstudio.rb file could be found in the installed OpenStudio folder: <paht_to_openstudio_installation>/openstudio-2.9.1/Ruby/openstudio.rb.

2. Clone the [OpenStudio-Standards](https://github.com/NREL/openstudio-standards) repository to your local machine. Set up the full path of openstudio-standards.rb in the [create_workflow.rb](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/code/create_workflow.rb#L24) scipt. The openstudio-standards.rb file could be found in the cloned OpenStudio-Standards repository.

3. Make sure [Ruby v2.2.4](https://www.ruby-lang.org/en/downloads/) is installed.

4. Set up the arguments in the [create_workflow.rb](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/code/create_workflow.rb#L340-L362).
This allows you to create models and run simulations for different building types, vintages, climate zones
    * Step 1. Select the [climate zone(s)](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/code/create_workflow.rb#L376-L393) for simulation. 
    The available climate zones are in the following array. 
    Uncomment the line(s) to specify the climate zone(s) you want to include:
        
        ```ruby
        climate_zones = [
            'ASHRAE 169-2006-1A',     # Considered in the synthetic operatin dataset
            # 'ASHRAE 169-2006-2A',
            # 'ASHRAE 169-2006-2B',
            # 'ASHRAE 169-2006-3A',
            # 'ASHRAE 169-2006-3B',
            'ASHRAE 169-2006-3C',     # Considered in the synthetic operatin dataset
            # 'ASHRAE 169-2006-4A',
            # 'ASHRAE 169-2006-4B',
            # 'ASHRAE 169-2006-4C',
            'ASHRAE 169-2006-5A',     # Considered in the synthetic operatin dataset
            # 'ASHRAE 169-2006-5B',
            # 'ASHRAE 169-2006-6A',
            # 'ASHRAE 169-2006-6B',
            # 'ASHRAE 169-2006-7A',
            # 'ASHRAE 169-2006-8A',
        ]
        ```
    * Step 2. [Prepare the weather files (EPWs) and map the their folder to the climate zones.](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/code/create_workflow.rb#L397-L402)
    For example, this repository provides 30 years' historical and a TMY3 weather files for three U.S. cities - 
    Chicago, Miami, and San Francicso. The weather files are saved in ```./EPWs/<city name>_AMY```. And the Hash below
    maps the climate zones of the three cities and the weather file to be used in the simulations. 
        ```ruby
        hash_climate_epw = {
            # 'climate zone option' => 'EPWs folder name', (example convention)
            'ASHRAE 169-2006-1A' => 'Miami_AMY',
            'ASHRAE 169-2006-3C' => 'SF_AMY',
            'ASHRAE 169-2006-5A' => 'Chicago_AMY',
        }
        ```
        You need to provide weather files and mapping rule for buildings in other climate zones.
    
    * Step 3. [Select the vintages you want to consider.](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/code/create_workflow.rb#L406-L411)
        ```ruby
        vintages = [
            # '90.1-2004',
            # '90.1-2007',
            # '90.1-2010',
            '90.1-2013'     # Considered in the synthetic operatin dataset
        ]
        ```
    
    * [Step 4. Select the building type to consider.](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/code/create_workflow.rb#L416-L442)
      Please note that occupancy_simulator only works for office buildings.
      ```ruby
        building_types = [
            ###############################################################
            ## building types that support stochastic occupancy simulation
            ###############################################################
            # 'SmallOffice',
            # 'MediumOffice',
            # 'LargeOffice',
            # 'SmallOfficeDetailed',
            'MediumOfficeDetailed',     # Considered in the synthetic operatin dataset
            # 'LargeOfficeDetailed',
            ###############################################################
            ## building types that do not support stochastic occupancy simulation
            ###############################################################
            # 'SecondarySchool',
            # 'PrimarySchool',
            # 'SmallHotel',
            # 'LargeHotel',
            # 'Warehouse',
            # 'RetailStandalone',
            # 'RetailStripmall',
            # 'QuickServiceRestaurant',
            # 'FullServiceRestaurant',
            # 'MidriseApartment',
            # 'HighriseApartment',
            # 'Hospital',
            # 'Outpatient',
        ]
        ```

    * Step 5. [Set the number of stochastic occupancy simulations for each building model.](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/code/create_workflow.rb#L445)
        ```ruby
        number_of_stochastic_occupancy_simulation = 5
        ```
    
    * Step 6. [Set the energy efficiency level (1 - low, 2 - standard, 3 - high) to run.](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/code/create_workflow.rb#L448)
        ```ruby
        efficiency_level = 2
        ```

5. Run the create_workflow.rb script with ```<ruby 2.2.4 command> create_workflow.rb``` The script will generate and run OpenStudio workflows to output the synthetic building operation data.

6. Post-processing. The above routine automatically generates OpenStudio models and runs the simulations.
This [Python script](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/code/results_extraction_demo.py) shows an example of extracting the raw CSV outputs and saving them in a structured way.
Depending on their purpose, readers may need develop custom routines to process the simulation results. 


## License
Refer to [License.txt](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/License.txt)