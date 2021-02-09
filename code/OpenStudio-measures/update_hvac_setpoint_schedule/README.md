

###### (Automatically generated documentation)

# Update HVAC Setpoint schedule

## Description
This measure helps create a new thermostat for each conditioned thermal zone, and generate random heating and cooling setpoints based on a Gaussin distribution.

## Modeler Description

    This measure helps create a new thermostat for each conditioned thermal zone, and generate random heating and cooling setpoints based on a Gaussin distribution.
      

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### The mean of the heating setpoint temperature.

**Name:** heating_setpoint_mean,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### The mean of the cooling setpoint temperature.

**Name:** cooling_setpoint_mean,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### The standard deviation of the heating setpoint temperature.

**Name:** heating_setpoint_stdev,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### The standard deviation of the cooling setpoint temperature.

**Name:** cooling_setpoint_stdev,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### The heating setback temperature.

**Name:** heating_setpoint_setback,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### The cooling setback temperature.

**Name:** cooling_setpoint_setback,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false




