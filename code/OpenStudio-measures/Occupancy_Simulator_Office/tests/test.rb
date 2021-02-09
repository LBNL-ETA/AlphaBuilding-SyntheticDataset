# *** Copyright Notice ***

# OS Measures Copyright (c) 2018, The Regents of the University of California, 
# through Lawrence Berkeley National Laboratory (subject to receipt of any required 
#   approvals from the U.S. Dept. of Energy). All rights reserved.

# If you have questions about your rights to use or distribute this software, 
# please contact Berkeley Lab's Innovation & Partnerships Office at  IPO@lbl.gov.

# NOTICE.  This Software was developed under funding from the U.S. Department of 
# Energy and the U.S. Government consequently retains certain rights. As such, 
# the U.S. Government has been granted for itself and others acting on its behalf 
# a paid-up, nonexclusive, irrevocable, worldwide license in the Software to 
# reproduce, distribute copies to the public, prepare derivative works, and 
# perform publicly and display publicly, and to permit other to do so. 

# ****************************

require 'openstudio' # Note: The measure is available with OpenStuio >= 2.7.0
require 'openstudio/ruleset/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb'
require 'fileutils'

require 'openstudio-standards.rb'

class OccupancySimulatorTest < Minitest::Test

  def create_model(building_type, vintage, climate_zone, osm_directory)
      model = OpenStudio::Model::Model.new
      @debug = false
      epw_file = 'Not Applicable'
      prototype_creator = Standard.build("#{vintage}_#{building_type}")
      prototype_creator.model_create_prototype_model(climate_zone, epw_file, osm_directory, @debug, model)
  end

  def setup
    # Create a small office reference model for the testing
    path = File.dirname(__FILE__)
    building_type = 'SmallOffice'
    vintage = '90.1-2004'
    climate_zone = 'ASHRAE 169-2006-1A'
    osm_directory = path
    create_model(building_type, vintage, climate_zone, osm_directory)

    # Move the model to the test main folder
    FileUtils.mv(path + '/SR1/in.osm', path + '/test_model.osm')
    FileUtils.mv(path + '/SR1/in.idf', path + '/test_model.idf')
    FileUtils.mv(path + '/SR1/in.epw', path + '/test_model.epw')
  end

  def test_argument_size_and_default_values
    # load the test model generated in the setup
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = File.dirname(__FILE__)
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/test_model.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # create an instance of the measure
    measure = OccupancySimulator.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure::convertOSArgumentVectorToMap(arguments)
    
    # Test the size of the arguments
    assert_equal(6, arguments.size)

    # Test the default values of the arguments
    args_hash = {}
    args_hash['Space_1_Perimeter_ZN_1'] = 'Office Type 1'
    args_hash['Space_2_Perimeter_ZN_2'] = 'Office Type 1'
    args_hash['Space_3_Perimeter_ZN_3'] = 'Office Type 1'
    args_hash['Space_4_Perimeter_ZN_4'] = 'Office Type 1'
    args_hash['Space_5_Core_ZN'] = 'Office Type 1'
    args_hash['Space_6_Attic'] = 'Other'
    arguments.each do |arg|
      arg_temp = arg.clone
      if args_hash[arg.name]
        assert(arg_temp.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = arg_temp
    end
  end

  def test_measure_run
    # load the test model generated in the setup
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = File.dirname(__FILE__)
    path = OpenStudio::Path.new(File.dirname(__FILE__) + "/test_model.osm")
    model = translator.loadModel(path)
    assert((not model.empty?))
    model = model.get

    # create an instance of the measure
    measure = OccupancySimulator.new
    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure::convertOSArgumentVectorToMap(arguments)
    assert(measure.run(model, runner, argument_map))

    v_schedule_files = model.getScheduleFiles
    assert_equal(5, v_schedule_files.length)
  end


  def teardown
    FileUtils.rm_f('./OccSimulator_out_IDF.csv')
    FileUtils.rm_rf('./SR1')
    FileUtils.rm_f('./SR1')
  end
end