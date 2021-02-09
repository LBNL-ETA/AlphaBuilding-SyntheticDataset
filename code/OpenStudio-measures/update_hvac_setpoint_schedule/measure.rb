# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class UpdateHVACSetpointSchedule < OpenStudio::Measure::ModelMeasure

  @@heating_summer_design_t = 15.56
  @@heating_winter_design_t = 21.11
  @@heating_default_day_t = 15.56
  @@cooling_summer_design_t = 23.89
  @@cooling_winter_design_t = 29.44
  @@cooling_default_day_t = 23.89

  @@default_heating_setpoint_mean = 22.81
  @@default_cooling_setpoint_mean = 23.72
  @@default_heating_setpoint_stdev = 1.87
  @@default_cooling_setpoint_stdev = 1.19
  @@default_heating_setpoint_setback = 15.56
  @@default_cooling_setpoint_setback =  29.44

  @@default_time_on = 6
  @@default_time_off = 18
  @@default_time_end = 24

  # Space type names whose thermostat setpoint will not be changed.  
  @@v_other_space_types = [
    'Office Attic',
    'Attic',
    'Plenum',
    'Plenum Space Type',
    'SmallOffice - Corridor',
    'SmallOffice - Lobby',
    'SmallOffice - Attic',
    'SmallOffice - Restroom',
    'SmallOffice - Stair',
    'SmallOffice - Storage',
    'MediumOffice - Corridor',
    'MediumOffice - Dining',
    'MediumOffice - Restroom',
    'MediumOffice - Lobby',
    'MediumOffice - Storage',
    'MediumOffice - Stair',
    'LargeOffice - Corridor',
    'LargeOffice - Dining',
    'LargeOffice - Restroom',
    'LargeOffice - Lobby',
    'LargeOffice - Storage',
    'LargeOffice - Stair',
    ''
  ]


  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Update HVAC Setpoint schedule'
  end

  # human readable description
  def description
    return 'This measure helps create a new thermostat for each conditioned thermal zone, and generate random heating and cooling setpoints based on a Gaussin distribution.'
  end

  # human readable description of modeling approach
  def modeler_description
    return '''
    This measure helps create a new thermostat for each conditioned thermal zone, and generate random heating and cooling setpoints based on a Gaussin distribution.
      '''
  end

  class RandomGaussian
    def initialize(mean = 0.0, sd = 1.0, range = lambda { Kernel.rand })
      @mean, @sd, @range = mean, sd, range
      @next_pair = false
    end

    def rand
      if (@next_pair = !@next_pair)
        # Compute a pair of random values with normal distribution.
        # See http://en.wikipedia.org/wiki/Box-Muller_transform
        theta = 2 * Math::PI * @range.call
        scale = @sd * Math.sqrt(-2 * Math.log(1 - @range.call))
        @g1 = @mean + scale * Math.sin(theta)
        @g0 = @mean + scale * Math.cos(theta)
      else
        @g1
      end
    end
  end

  def addThermostat(model, space, heating_setpoint, heating_setback, cooling_setpoint, cooling_setback, sch_type_lmimit)
    '''
    This function add a dual setpoint thermostat object to the specified space in the model with given heating and cooling setpoint and setback temperatures
    '''

    thermal_zone_name = space.thermalZone.get.nameString
    schTypeLimits = sch_type_lmimit

    # # 0. Create new ScheduleTypeLimits
    # schTypeLimits = OpenStudio::Model::ScheduleTypeLimits.new(model)
    # schTypeLimits.setName('Tempearture')
    # schTypeLimits.setNumericType('Continuous')
    # schTypeLimits.setUnitType('Temperature')

    # 1. Create new OS:Schedule:Ruleset for both heating and cooling setpoints
    h_schRuleSet = OpenStudio::Model::ScheduleRuleset.new(model)
    h_schRuleSet.setName('Schedule Rule Set for heating setpoint of thermal zone ' + thermal_zone_name)
    c_schRuleSet = OpenStudio::Model::ScheduleRuleset.new(model)
    c_schRuleSet.setName('Schedule Rule Set for cooling setpoint of thermal zone ' + thermal_zone_name)

    # Create the summer and winter design day schedule
    time_on = OpenStudio::Time.new(0, @@default_time_on, 0, 0)
    time_off = OpenStudio::Time.new(0, @@default_time_off, 0, 0)
    time_end = OpenStudio::Time.new(0, @@default_time_end, 0, 0)

    h_schSummerDesignDay = OpenStudio::Model::ScheduleDay.new(model)
    h_schWinterDesignDay = OpenStudio::Model::ScheduleDay.new(model)
    h_schDefaultDay = OpenStudio::Model::ScheduleDay.new(model)
    h_schSummerDesignDay.setName('Heating conditioned zone summer design day schedule for thermal zone ' + thermal_zone_name)
    h_schWinterDesignDay.setName('Heating conditioned zone winter design day schedule for thermal zone ' + thermal_zone_name)
    h_schDefaultDay.setName('Heating conditioned zone default day schedule for thermal zone ' + thermal_zone_name)
    h_schSummerDesignDay.addValue(time_end, @@heating_summer_design_t)
    h_schWinterDesignDay.addValue(time_end, @@heating_winter_design_t)
    h_schRuleSet.defaultDaySchedule.addValue(time_end, @@heating_default_day_t) # check
    h_schRuleSet.setScheduleTypeLimits(schTypeLimits)
    h_schRuleSet.setSummerDesignDaySchedule(h_schSummerDesignDay)
    h_schRuleSet.setWinterDesignDaySchedule(h_schWinterDesignDay)

    c_schSummerDesignDay = OpenStudio::Model::ScheduleDay.new(model)
    c_schWinterDesignDay = OpenStudio::Model::ScheduleDay.new(model)
    c_schDefaultDay = OpenStudio::Model::ScheduleDay.new(model)
    c_schSummerDesignDay.setName('Cooling conditioned zone summer design day schedule for thermal zone ' + thermal_zone_name)
    c_schWinterDesignDay.setName('Cooling conditioned zone winter design day schedule for thermal zone ' + thermal_zone_name)
    c_schRuleSet.defaultDaySchedule.setName('Cooling conditioned zone default day schedule for thermal zone ' + thermal_zone_name)
    c_schSummerDesignDay.addValue(time_end, @@cooling_summer_design_t)
    c_schWinterDesignDay.addValue(time_end, @@cooling_winter_design_t)
    c_schRuleSet.defaultDaySchedule.addValue(time_end, @@cooling_default_day_t) # check
    c_schRuleSet.setScheduleTypeLimits(schTypeLimits)
    c_schRuleSet.setSummerDesignDaySchedule(c_schSummerDesignDay)
    c_schRuleSet.setWinterDesignDaySchedule(c_schWinterDesignDay)

    # 2. Create new OS:Schedule:Rule
    ## heating
    h_schRule = OpenStudio::Model::ScheduleRule.new(h_schRuleSet)
    h_schRule.setName('Heating Schedule rule for thermal zone' + thermal_zone_name)
    h_schRule.daySchedule.setName('Zone' + thermal_zone_name + ' Dual setpoints - heating')
    h_schRule.daySchedule.addValue(time_on, heating_setback)
    h_schRule.daySchedule.addValue(time_off, heating_setpoint)
    h_schRule.daySchedule.addValue(time_end, heating_setback)
    s_date = OpenStudio::Date.new()
    h_schRule.setStartDate(s_date)
    h_schRule.setApplyMonday(true)
    h_schRule.setApplyTuesday(true)
    h_schRule.setApplyWednesday(true)
    h_schRule.setApplyThursday(true)
    h_schRule.setApplyFriday(true)

    ## cooling
    c_schRule = OpenStudio::Model::ScheduleRule.new(c_schRuleSet)
    c_schRule.setName('Cooling Schedule rule for thermal zone' + thermal_zone_name)
    c_schRule.daySchedule.setName('Zone ' + thermal_zone_name + ' Dual setpoints - cooling')
    c_schRule.daySchedule.addValue(time_on, cooling_setback)
    c_schRule.daySchedule.addValue(time_off, cooling_setpoint)
    c_schRule.daySchedule.addValue(time_end, cooling_setback)
    s_date = OpenStudio::Date.new()
    c_schRule.setStartDate(s_date)
    c_schRule.setApplyMonday(true)
    c_schRule.setApplyTuesday(true)
    c_schRule.setApplyWednesday(true)
    c_schRule.setApplyThursday(true)
    c_schRule.setApplyFriday(true)

    # 3. Create new thermostat and Assign heating and cooling setpoint schedule to the thermostat
    thermostat = OpenStudio::Model::ThermostatSetpointDualSetpoint.new(model)
    thermostat.setHeatingSetpointTemperatureSchedule(h_schRuleSet)
    thermostat.setCoolingSetpointTemperatureSchedule(c_schRuleSet)

    # 4. Set the new thermostat setpoints for the thermostat
    space.thermalZone.get.setThermostatSetpointDualSetpoint(thermostat)

    return model
  end


  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Enable user inputs of the thermostat setpoint distribution
    heating_setpoint_mean = OpenStudio::Measure::OSArgument.makeDoubleArgument('heating_setpoint_mean', true)
    cooling_setpoint_mean = OpenStudio::Measure::OSArgument.makeDoubleArgument('cooling_setpoint_mean', true)
    heating_setpoint_stdev = OpenStudio::Measure::OSArgument.makeDoubleArgument('heating_setpoint_stdev', true)
    cooling_setpoint_stdev = OpenStudio::Measure::OSArgument.makeDoubleArgument('cooling_setpoint_stdev', true)
    heating_setpoint_setback = OpenStudio::Measure::OSArgument.makeDoubleArgument('heating_setpoint_setback', true)
    cooling_setpoint_setback = OpenStudio::Measure::OSArgument.makeDoubleArgument('cooling_setpoint_setback', true)

    heating_setpoint_mean.setDisplayName('The mean of the heating setpoint temperature.')
    cooling_setpoint_mean.setDisplayName('The mean of the cooling setpoint temperature.')
    heating_setpoint_stdev.setDisplayName('The standard deviation of the heating setpoint temperature.')
    cooling_setpoint_stdev.setDisplayName('The standard deviation of the cooling setpoint temperature.')
    heating_setpoint_setback.setDisplayName('The heating setback temperature.')
    cooling_setpoint_setback.setDisplayName('The cooling setback temperature.')

    heating_setpoint_mean.setDefaultValue(@@default_heating_setpoint_mean)
    cooling_setpoint_mean.setDefaultValue(@@default_cooling_setpoint_mean)
    heating_setpoint_stdev.setDefaultValue(@@default_heating_setpoint_stdev)
    cooling_setpoint_stdev.setDefaultValue(@@default_cooling_setpoint_stdev)
    heating_setpoint_setback.setDefaultValue(@@default_heating_setpoint_setback)
    cooling_setpoint_setback.setDefaultValue(@@default_cooling_setpoint_setback)

    args << heating_setpoint_mean
    args << cooling_setpoint_mean
    args << heating_setpoint_stdev
    args << cooling_setpoint_stdev
    args << heating_setpoint_setback
    args << cooling_setpoint_setback

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end


    # report initial condition of model
    runner.registerInitialCondition("Start.")

    heating_setpoint_mean = runner.getDoubleArgumentValue('heating_setpoint_mean', user_arguments)
    cooling_setpoint_mean = runner.getDoubleArgumentValue('cooling_setpoint_mean', user_arguments)
    heating_setpoint_stdev = runner.getDoubleArgumentValue('heating_setpoint_stdev', user_arguments)
    cooling_setpoint_stdev = runner.getDoubleArgumentValue('cooling_setpoint_stdev', user_arguments)
    heating_setpoint_setback = runner.getDoubleArgumentValue('heating_setpoint_setback', user_arguments)
    cooling_setpoint_setback = runner.getDoubleArgumentValue('cooling_setpoint_setback', user_arguments)

    v_space_types = model.getSpaceTypes

    # Create a schedule type limits for the thermostat setpoints
    sch_type_lmimit = OpenStudio::Model::ScheduleTypeLimits.new(model)
    sch_type_lmimit.setName('Tempearture')
    sch_type_lmimit.setNumericType('Continuous')
    sch_type_lmimit.setUnitType('Temperature')

    v_space_types.each do |space_type|
      if not @@v_other_space_types.include? space_type.standardsSpaceType.to_s
        v_current_spaces = space_type.spaces
        v_current_spaces.each do |current_space|
          puts 'Adding thermostat for '+ current_space.thermalZone.get.nameString
          heating_setpoint = RandomGaussian.new(heating_setpoint_mean, heating_setpoint_stdev).rand.round(2)
          heating_setback = heating_setpoint_setback
          cooling_setpoint = RandomGaussian.new(cooling_setpoint_mean, cooling_setpoint_stdev).rand.round(2)
          cooling_setback = cooling_setpoint_setback
          if heating_setpoint >= cooling_setpoint
            heating_setpoint = @@default_heating_setpoint_mean
            cooling_setpoint = @@default_cooling_setpoint_mean
          end
          model = addThermostat(model, current_space, heating_setpoint, heating_setback, cooling_setpoint, cooling_setback, sch_type_lmimit)
        end
      end
    end

    # echo the new space's name back to the user
    runner.registerInfo("New thermostats were added to the spaces")

    # report final condition of model
    runner.registerFinalCondition("The building finished with #{model.getSpaces.size} spaces.")

    return true
  end
end

# register the measure to be used by the application
UpdateHVACSetpointSchedule.new.registerWithApplication
