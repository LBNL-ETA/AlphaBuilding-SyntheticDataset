## A Synthetic Building Operation Dataset

***Prepared by:*** [**Han Li**](https://github.com/tsbyq)

This repository is prepared for a dataset descriptor - A Synthetic Building Operation Dataset submitted to the [Scientific Data](https://www.nature.com/sdata/) journal. It contains:
1. A brief introduction to the dataset.
2. A Jupyter notebook with Python script to extract and visualize the data.
3. A steps to re-produce the dataset.
3. A discussion of example use cases of the dataset. 



### ***About the dataset:***

This is a synthetic building operation dataset which includes HVAC, lighting, miscellaneous electric loads (MELs) system operating conditions, occupant counts, environmental parameters, end-use and whole-building energy consumptions at 10-minute intervals. The data is created with 1395 annual simulations using the U.S. DOE detailed medium-sized reference office building, and 30 years’ historical weather data in three typical climates including Miami, San Francisco, and Chicago. Three energy efficiency levels of the building and systems are considered. Assumptions regarding occupant movements, occupants’ diverse temperature preferences, lighting, and MELs are adopted to reflect realistic building operations. A semantic building metadata schema - BRICK, is used to store the building metadata. The dataset is saved in a 1.2 TB of compressed HDF5 file. This dataset can be used in various applications, including building energy and load shape benchmarking, energy model calibration, evaluation of occupant and weather variability and their influences on building performance, algorithm development and testing for thermal and energy load prediction, model predictive control, policy development for reinforcement learning based building controls. The data is currently hosted on Google Drive and can be downloaded at [this link](https://drive.google.com/file/d/1DLy1LbxICQda_M1Ez6Qh-JG-Q_CjKM8G/view?usp=sharing)



### ***Data Extraction and Visualization:***

This [Jupyter notebook](https://github.com/tsbyq/AlphaBuilding-A-Synthetic-Building-Operation-Dataset/blob/gh-pages/A%20Synthetic%20Operation%20Dataset.ipynb) contains Python scripts, dependencies, functions to extract and explore the dataset. 


### ***Reproduce the dataset:***

### ***Example use cases:***
The developed dataset can be used for a wide array of applications. Here, we illustrated two use cases of the large-scale high-resolution data we generated: benchmarking and data-driven building control.

#### Building Performance Benchmarking
The generated energy consumption and indoor environmental quality data can be used to benchmark various envelope, control and advanced building technologies, especially for areas where real measurement data is not available or inadequate. For instance, even though BPD is the largest database of measured building energy performance in the United States, the sample size of buildings in Miami is 136, which might be too small for robust benchmarking. In this case, the simulation data we generated can be a valuable complementary. The dataset provides system-level end uses and their load profiles for fine granular benchmarking, which are often hard to get from measured datasets. The temporal characteristics - high-load start time, end time, duration, and peak-to-base ratio, could be extracted from the synthetic load profiles and used to benchmark the real building load profiles.


#### Data-driven Building Control
Conventional control techniques, such as PID control, are unable to adapt to the changing building dynamics (due to different occupant behaviors, and building retrofits etc.), to balance the trade-off between multiple objectives (e.g., comfort, energy, costs, and carbon emission), and to respond to the demand signal efficiently. With the rapid development of machine learning (ML) algorithms and computational power, data-driven control becomes a promising alternative for [building control][1]. 
Data-driven control learns the control law, a mapping from the current states (s) to control actions (a) π_(a|s), directly from the building operational data. However, to train a robust, reliable and effective controller, high-quality data is a prerequisite. There are two reasons that it is challenging, if not impossible, to generate those data from building operations. First, the dataset needs to be huge, which requires buildings to operate for years. Second, the dataset needs to explore the state-action space as much as possible, so that the controller would not be stuck in the local optimal. Unfortunately, the existing operational data are likely to be generated from Rule Based Control (RBC), following a given set of rules. Therefore the real operational data usually locates in a limited portion of the state-action space. In this regard, the building operational data generated from simulation could be more valuable for data-driven building control for two reasons. First, it is cheap and fast to generate a huge amount of data through simulation to consider different building operation conditions and disturbances such as weather, occupancy, and etc. Second, and more importantly, different control logics could be tried through simulation without worrying about compromising the indoor environment. In real building practice, building operators are unwilling to try different control logics due to the risks of poor indoor environments. This concern does not exist in a simulation environment. Therefore, the controller could test different control laws to find the optimal one. 
We introduced a concrete example of how the simulation data can be used to train a data-driven controller through imitation learning. The whole point of training a controller is to learn the mapping relation from states to actions, π_(a|s). There is a whole branch of machine learning algorithms on this topic - [Reinforcement Learning (RL)][2]. Imitation Learning (IL) is one algorithm of RL. The key idea of IL is instead of trying different control laws and finding the best one, why not imitate the behavior of an expert controller. We applied IL to train a purely data-driven controller using the simulation dataset we generated through the following three steps. First, we identified the ASHRAE Guideline 36, the cutting-edge HVAC control sequence used by the industry, as the expert to follow. Then, we implemented ASHRAE Guideline 36 in EnergyPlus and used it to generate building operational data (a subset of the developed dataset) under different ambient environments and disturbances. Third, we trained our controller to clone the behavior of ASHRAE Guideline 36, i.e., what the output of the expert (action) is given a specific situation (states). This is a typical supervised learning task. We compared the actions suggested by ASHRAE Guideline 36 and those suggested by the IL controller of a typical summer week. As shown in the figure below, these two controllers have similar behaviors. 

![image info](./example.png)

[1]: https://www.sciencedirect.com/science/article/pii/S0378778819337879

[2]: https://www.sciencedirect.com/science/article/abs/pii/S0306261920305481




<!-- ### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/tsbyq/Synthetic_Operation_Data/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://docs.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.
 -->
