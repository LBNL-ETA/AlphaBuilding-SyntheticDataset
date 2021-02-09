
# Change to the path where OS is installed
require '<place_holder>/openstudio-2.9.1/Ruby/openstudio.rb'
require '<place_holder>/openstudio-standards/lib/openstudio-standards.rb'
require 'fileutils'
require 'parallel'


def loadOSM(pathStr)
  translator = OpenStudio::OSVersion::VersionTranslator.new
  path = OpenStudio::Path.new(pathStr)
  model = translator.loadModel(path)
  if model.empty?
    raise "Input #{pathStr} is not valid, please check."
  else
    model = model.get
  end
  return model
end


def create_single_model(building_type, vintage, climate_zone, osm_directory)
    model = OpenStudio::Model::Model.new
    @debug = false
    epw_file = 'Not Applicable'
    prototype_creator = Standard.build("#{vintage}_#{building_type}")
    prototype_creator.model_create_prototype_model(climate_zone, epw_file, osm_directory, @debug, model)
end

def create_workflows(building_types,
                     vintages,
                     climate_zones,
                     root_directory,
                     epws_path,
                     measures_dir=nil,
                     n_runs=5,
                     efficiency_level=2)

    unless File.directory?(File.expand_path(root_directory))
        FileUtils.mkdir_p(File.expand_path(root_directory))
    end

    hash_climate_epw = {
        'ASHRAE 169-2006-1A' => 'Miami_AMY',
        'ASHRAE 169-2006-3C' => 'SF_AMY',
        'ASHRAE 169-2006-5A' => 'Chicago_AMY',
    }
    hash_eff_level = {
        1 => 'Low',
        2 => 'Standard',
        3 => 'High',
    }
    out_osw_dir = File.expand_path(File.join(root_directory, "3~OSWs", "efficiency_level_#{hash_eff_level[efficiency_level]}"))
    v_osw_paths = []

    building_types.each do |building_type|
        climate_zones.each do |climate_zone|
            sub_epws_path = File.expand_path(File.join(epws_path, hash_climate_epw[climate_zone]))
            vintages.each do |vintage|
                ## 1. Generate and prepare OSM
                model_name = building_type + '_' + vintage + '_' + climate_zone.split('-').last.to_s
                seed_model_folder = File.join(root_directory, '1~seeds', model_name)
                new_model_folder = File.join(root_directory, '2~processed_models', "efficiency_level_#{hash_eff_level[efficiency_level]}", model_name)
                old_osm_path = File.expand_path(File.join(seed_model_folder, 'SR1/in.osm'))
                old_epw_path = File.expand_path(File.join(seed_model_folder, 'SR1/in.epw'))
                new_osm_path = File.expand_path(File.join(new_model_folder, "#{model_name}.osm"))
                new_epw_path = File.expand_path(File.join(new_model_folder, "#{model_name}.epw"))
                ## Create raw building model
                create_single_model(building_type, vintage, climate_zone, seed_model_folder)
                ## Process model
                process_model(old_osm_path, new_osm_path, efficiency_level)
                FileUtils.mv(old_epw_path, new_epw_path)
                ## 2. Prepare OSW
                v_epw_paths = Dir.glob("#{sub_epws_path}/*.epw")
                v_osw_paths += prepare_all_osws(new_osm_path, v_epw_paths, out_osw_dir, measures_dir, n_runs)

            end
        end
    end
    f = File.new(File.join(root_directory, "job_efficiency_level_#{hash_eff_level[efficiency_level]}.txt"), "w")
    f.write(v_osw_paths)
    f.close
    return v_osw_paths
end

def process_model(old_osm_path, new_osm_path, efficiency_level=2)
    osm_dir = File.dirname(new_osm_path)
    unless File.directory?(osm_dir)
        FileUtils.mkdir_p(osm_dir)
    end

    # Do the following:
    # 1. Change the simulation run period to match weather data
    model = loadOSM(old_osm_path)
    model.getSimulationControl.setRunSimulationforSizingPeriods(false)
    model.getSimulationControl.setRunSimulationforWeatherFileRunPeriods(true)

    # 2. Enable CO2 simulations
    # model.getZoneAirContaminantBalance.setCarbonDioxideConcentration(true)

    # 3. Change the VAV control logic to dual-maximum
    vav_reheats = model.getAirTerminalSingleDuctVAVReheats
    vav_reheats.each do |vav_reheat|
        vav_reheat.setDamperHeatingAction('ReverseWithLimits')
    end

    # 4. Change the efficiency level (TBD)
    model = adjust_efficiency_level(model, efficiency_level)

    # Save processed model
    model.save(new_osm_path, true)
end


def adjust_efficiency_level(model, level=2)
    # Efficiency levels:
    # 1 - low
    # 2 - standard
    # 3 - high

    if level == 2
        puts 'Keep the default efficiency level.'
        return model
    else
        if level == 1
            puts 'Adjusting to low efficiency level.'
            factor = 1.25
        elsif level == 3
            puts 'Adjusting to high efficiency level.'
            factor = 0.75
        end
    end

    
    # 1. Lighting
    v_light_defs = model.getLightsDefinitions
    v_light_defs.each do |light_def|
        old_lpd = light_def.wattsperSpaceFloorArea.to_f
        light_def.setWattsperSpaceFloorArea(old_lpd * factor)
    end

    # 2. MELs
    v_equip_defs = model.getElectricEquipmentDefinitions
    v_equip_defs.each do |equip_def|
        if equip_def.designLevelCalculationMethod == 'Watts/Area'
            equip_def.setWattsperSpaceFloorArea(equip_def.wattsperSpaceFloorArea.to_f * factor)
        elsif equip_def.designLevelCalculationMethod == 'EquipmentLevel'
            equip_def.setDesignLevel(equip_def.designLevel.to_f * factor)
        end
    end

    # 3. Wall insulation
    v_opaque_materials = model.getStandardOpaqueMaterials
    v_opaque_materials.each do |opaque_material|
        opaque_material.setThermalConductivity(opaque_material.thermalConductivity.to_f * factor)
    end


    # 4. Windows
    v_glazing_materials = model.getGlazings
    v_glazing_materials.each do |glazing_material|
        glazing_material.setThickness(glazing_material.thickness.to_f / factor)
    end

    # 5. Cooling plant
    v_cooling_coils = model.getCoilCoolingDXTwoSpeeds
    v_cooling_coils.each do |cooling_coil|
        cooling_coil.setRatedLowSpeedCOP(cooling_coil.ratedLowSpeedCOP.to_f / factor)
        cooling_coil.setRatedHighSpeedCOP(cooling_coil.ratedHighSpeedCOP.to_f / factor)
    end

    # 6. Heating plant
    v_heating_coils = model.getCoilHeatingGass
    v_heating_coils.each do |heating_coil|
        # Set highest efficiency to be 0.95
        heating_coil.setGasBurnerEfficiency([0.95, heating_coil.gasBurnerEfficiency.to_f / factor].min)
    end

    v_reheating_coils = model.getCoilHeatingElectrics
    v_reheating_coils.each do |reheating_coil|
        reheating_coil.setEfficiency([1, reheating_coil.efficiency.to_f / factor].min) 
    end

    v_water_heaters = model.getWaterHeaterMixeds
    v_water_heaters.each do |water_heater|
        water_heater.setHeaterThermalEfficiency([0.95, water_heater.heaterThermalEfficiency.to_f / factor].min)
    end

    # 7. Fans
    v_fans = model.getFanVariableVolumes
    v_fans.each do |fan|
        fan.setFanTotalEfficiency([0.8, fan.fanTotalEfficiency.to_f / factor].min)
        fan.setMotorEfficiency([0.95, fan.motorEfficiency.to_f / factor].min)
    end

    # 8. Pumps
    v_pumps = model.getPumpConstantSpeeds
    v_pumps.each do |pump|
        pump.setMotorEfficiency([0.6, pump.motorEfficiency.to_f / factor].min)
    end

    return model
end


def prepare_single_osw(seed_osm_path, epw_path, measures_dir, osw_path)
    # Prepare OSW to add dynamic occupancy, lighting, MELs schedules.
    osw_dir = File.dirname(osw_path)
    unless File.directory?(osw_dir)
        FileUtils.mkdir_p(osw_dir)
    end
    osw_str = 
%({
    "weather_file": "#{epw_path}",
    "seed_file": "#{seed_osm_path}",
    "measure_paths": [
        "#{measures_dir}"
    ],
    "steps": [
        {"arguments": {},"measure_dir_name": "Occupancy_Simulator_Office"},
        {"arguments": {},"measure_dir_name": "create_lighting_schedule_from_occupant_count"},
        {"arguments": {},"measure_dir_name": "create_mels_schedule_from_occupant_count"},
        {"arguments": {},"measure_dir_name": "update_hvac_setpoint_schedule"},
        {"arguments": {},"measure_dir_name": "add_demand_controlled_ventilation"},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Site Outdoor Air Drybulb Temperature","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Site Outdoor Air Dewpoint Temperature","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Site Outdoor Air Wetbulb Temperature","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Site Outdoor Air Relative Humidity","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Site Horizontal Infrared Radiation Rate per Area","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Site Day Type Index","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"System Node Pressure","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"System Node Temperature","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"System Node Mass Flow Rate","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"System Node Relative Humidity","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"System Node Relative Humidity","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Zone Mean Air Temperature","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Zone Air Relative Humidity","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Zone Thermostat Heating Setpoint Temperature","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Zone Thermostat Cooling Setpoint Temperature","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Air System Outdoor Air Economizer Status","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Zone Air Terminal VAV Damper Position","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Zone People Occupant Count","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Zone Electric Equipment Electric Power","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Zone Lights Electric Power","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Fan Electric Power","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Fan Air Mass Flow Rate","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Pump Electric Power","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Pump Mass Flow Rate","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddOutputVariable","arguments":{"variable_name":"Zone Mechanical Ventilation Mass Flow Rate","key_value":"*","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"InteriorLights:Electricity","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"InteriorEquipment:Electricity","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"Fans:Electricity","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"ExteriorLights:Electricity","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"Heating:Electricity","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"Cooling:Electricity","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"Gas:HVAC","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"Electricity:HVAC","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"Pumps:Electricity","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"Electricity:Facility","reporting_frequency":"timestep"}},
        {"measure_dir_name":"AddMeter","arguments":{"meter_name":"Gas:Facility","reporting_frequency":"timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Site Outdoor Air Drybulb Temperature","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Site Outdoor Air Dewpoint Temperature","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Site Outdoor Air Wetbulb Temperature","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Site Outdoor Air Relative Humidity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Site Horizontal Infrared Radiation Rate per Area","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Site Day Type Index","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"System Node Pressure","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"System Node Temperature","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"System Node Mass Flow Rate","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"System Node Relative Humidity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"System Node Relative Humidity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Zone Mean Air Temperature","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Zone Air Relative Humidity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Zone Thermostat Heating Setpoint Temperature","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Zone Thermostat Cooling Setpoint Temperature","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Air System Outdoor Air Economizer Status","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Zone Air Terminal VAV Damper Position","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Zone People Occupant Count","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Zone Electric Equipment Electric Power","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Zone Lights Electric Power","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Fan Electric Power","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Fan Air Mass Flow Rate","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Pump Electric Power","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Pump Mass Flow Rate","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportVariabletoCSV","arguments":{"variable_name":"Zone Mechanical Ventilation Mass Flow Rate","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"InteriorLights:Electricity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"InteriorEquipment:Electricity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"Fans:Electricity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"ExteriorLights:Electricity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"Heating:Electricity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"Cooling:Electricity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"Gas:HVAC","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"Electricity:HVAC","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"Pumps:Electricity","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"Electricity:Facility","reporting_frequency":"Zone Timestep"}},
        {"measure_dir_name":"ExportMetertoCSV","arguments":{"meter_name":"Gas:Facility","reporting_frequency":"Zone Timestep"}}
    ]
})

    f = File.new(osw_path, "w")
    f.write(osw_str)
    f.close
end

def prepare_all_osws(seed_osm_path, v_epw_paths, out_osw_dir, measures_dir, n_runs)
    # seed_osm_path - seed OS model
    # v_epw_paths - array of epw paths
    # out_osw_dir - directory where osw will be grouped and saved by each year's epw
    # measures_dir - directory where OS measures are saved
    # n_runs - i.e. n_runs of occupancy simulator runs for each epw
    
    v_osw_paths = []
    seed_osm_name = File.basename(seed_osm_path, ".osm")
    v_epw_paths.each do |epw_path|
        epw_name =  File.basename(epw_path, ".epw")
        year = epw_name[-2..-1]
        for i in 1..n_runs
            temp_osw_path = "#{out_osw_dir}/#{seed_osm_name}/#{epw_name}/run_#{i}/#{seed_osm_name}_run_#{i}.osw"
            prepare_single_osw(seed_osm_path, epw_path, measures_dir, temp_osw_path)
            v_osw_paths << temp_osw_path
        end
    end

    v_osw_paths
end

def run_osws(os_exe, v_osw_paths, number_of_threads)
    n = v_osw_paths.length
    Parallel.each_with_index(v_osw_paths, :in_threads => number_of_threads) do |osw_path, index|
      puts "Running #{index+1}/#{n}"
      command = "#{os_exe} run -w '#{osw_path}'"
      puts command
      system command
    end
end

################################################################################
## Main
################################################################################
climate_zones = [
    'ASHRAE 169-2006-1A',
    'ASHRAE 169-2006-3C',
    'ASHRAE 169-2006-5A',
]

building_types = ['MediumOfficeDetailed']
vintages = ['90.1-2013']
root_directory = './Models/'
measures_dir = './OpenStudio-measures'
epws_path = './EPWs'

starting = Time.now
v_osws = create_workflows(building_types = building_types,
                          vintages = vintages,
                          climate_zones = climate_zones,
                          root_directory = root_directory,
                          epws_path = epws_path,
                          measures_dir = measures_dir,
                          n_runs = 1,
                          efficiency_level = 3)

run_osws('os291', v_osws, 31)

ending = Time.now
elapsed = ending - starting
puts "Job started at #{starting}, finished at #{Time.now}, #{elapsed} seconds elapsed."