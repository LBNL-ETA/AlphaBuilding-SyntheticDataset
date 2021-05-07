# AlphaBuilding-SyntheticDataset

This repository is created for the AlphaBuilding-SyntheticDataset. Details about this dataset could be found on its [GitHub page](https://lbnl-eta.github.io/AlphaBuilding-SyntheticDataset/).

## Reproduce the Dataset
The source code to reproduce the dataset could be found in the code directory. Follow the steps below to reproduce the dataset:
1. Install [OpenStudio v2.9.1](https://github.com/NREL/OpenStudio/releases/tag/v2.9.1). 
Set up the full path of openstudio.rb in the [create_workflow.rb](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/8e975cce0113b1c39a5579a02c53adda7e32f8f5/code/create_workflow.rb#L3) script. 
The openstudio.rb file could be found in the installed OpenStudio folder: <paht_to_openstudio_installation>/openstudio-2.9.1/Ruby/openstudio.rb.

2. Clone the [OpenStudio-Standards](https://github.com/NREL/openstudio-standards) repository to your local machine. Set up the full path of openstudio-standards.rb in the [create_workflow.rb](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/8e975cce0113b1c39a5579a02c53adda7e32f8f5/code/create_workflow.rb#L4) scipt. The openstudio-standards.rb file could be found in the cloned OpenStudio-Standards repository.

3. Make sure [Ruby v2.2.4](https://www.ruby-lang.org/en/downloads/) is installed.

4. Set up the arguments in the [create_workflow.rb](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/8e975cce0113b1c39a5579a02c53adda7e32f8f5/code/create_workflow.rb#L340-L362).
This allows you to create models and run simulations for different building types, vintages, climate zones
    * Step 1. Select the climate zone(s) for simulation. The available climate zones are in the following array. 
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
    * Step 2. Select the climate zone(s) for simulation.
    

5. Run the create_workflow.rb script with ```ruby create_workflow.rb``` The script will generate and run OpenStudio workflows to output the synthetic building operation data.

6. Post-processing

## License
Refer to [License.txt](https://github.com/LBNL-ETA/AlphaBuilding-SyntheticDataset/blob/master/License.txt)