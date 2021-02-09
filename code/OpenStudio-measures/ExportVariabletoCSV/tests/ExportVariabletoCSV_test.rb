require 'openstudio'
require 'openstudio/ruleset/ShowRunnerOutput'
require 'minitest/autorun'
require 'fileutils'
require_relative '../measure.rb'

class ExportVariabletoCSV_Test < MiniTest::Test
  
  def model_path
    return "#{File.dirname(__FILE__)}/example_model.osm"
  end
  
  def run_dir
	return "#{File.dirname(__FILE__)}/example_model/"
  end
  
  def sql_path
    return "#{File.dirname(__FILE__)}/example_model/ModelToIdf/EnergyPlus-0/eplusout.sql"
  end

  def report_path
    return "#{File.dirname(__FILE__)}/report.html"
  end

  # create test files if they do not exist when the test first runs 
  def setup_test

	assert(File.exist?(model_path()))
	
	if !File.exist?(run_dir())
      FileUtils.mkdir_p(run_dir())
    end
    assert(File.exist?(run_dir()))    
	
    if File.exist?(report_path())
      FileUtils.rm(report_path())
    end

    if !File.exist?(sql_path())
      puts "Running EnergyPlus"

	  co = OpenStudio::Runmanager::ConfigOptions.new(true)
      co.findTools(false, true, false, true)
      
      wf = OpenStudio::Runmanager::Workflow.new("modeltoidf->energyplus")
      wf.add(co.getTools())
      job = wf.create(OpenStudio::Path.new(run_dir), OpenStudio::Path.new(model_path()))

      rm = OpenStudio::Runmanager::RunManager.new
      rm.enqueue(job, true)
      rm.waitForFinished
    end
  end

  def test_ExportMetertoCSV
	
    assert(File.exist?(model_path()))
	
	if !File.exist?(sql_path())
	  setup_test()
	end
    assert(File.exist?(sql_path()))

    # create an instance of the measure
	measure = ExportVariabletoCSV.new

    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new

    # get arguments
    arguments = measure.arguments()
	assert_equal(2, arguments.size)
    argument_map = OpenStudio::Ruleset.convertOSArgumentVectorToMap(arguments)
	
	# set argument values to good values and run the measure
    variable_name = arguments[0].clone
    assert(variable_name.setValue("Zone Outdoor Air Drybulb Temperature"))
    argument_map["variable_name"] = variable_name
	reporting_frequency = arguments[1].clone
    assert(reporting_frequency.setValue("Hourly"))
	argument_map["reporting_frequency"] = reporting_frequency

    # set up runner, this will happen automatically when measure is run in PAT or OpenStudio
    runner.setLastOpenStudioModelPath(OpenStudio::Path.new(model_path()))
    runner.setLastEnergyPlusSqlFilePath(OpenStudio::Path.new(sql_path()))

	# delete the output if it exists
    if File.exist?(report_path())
      FileUtils.rm(report_path())
    end
    assert(!File.exist?(report_path()))

    # temporarily change directory to the run directory and run the measure
    start_dir = Dir.pwd
    begin
      Dir.chdir(run_dir())

      # run the measure
      measure.run(runner, argument_map)
      result = runner.result
	  show_output(result)
      assert_equal("Success", result.value.valueName)
    ensure
      Dir.chdir(start_dir)
    end

	# make sure the report file exists
    #assert(File.exist?(report_path()))
  end

end
