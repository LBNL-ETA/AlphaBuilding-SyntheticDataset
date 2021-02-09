require 'erb'
require 'csv'

#start the measure
class ExportVariabletoCSV < OpenStudio::Ruleset::ReportingUserScript

  # human readable name
  def name
    return "ExportVariabletoCSV"
  end

  # human readable description
  def description
    return "Exports an OutputVariable specified in the AddOutputVariable OpenStudio measure to a csv file."
  end

  # human readable description of modeling approach
  def modeler_description
    return "This measure searches for the OutputVariable name in the eplusout sql file and saves it to a csv file."
  end

  # define the arguments that the user will input
  def arguments()
    args = OpenStudio::Ruleset::OSArgumentVector.new

    #make an argument for the variable name
    variable_name = OpenStudio::Ruleset::OSArgument::makeStringArgument("variable_name",true)
    variable_name.setDisplayName("Enter Variable Name.")
    args << variable_name
	
    #make an argument for the reporting frequency
    reporting_frequency_chs = OpenStudio::StringVector.new
    reporting_frequency_chs << "Hourly"
    reporting_frequency_chs << "Zone Timestep"
    reporting_frequency = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('reporting_frequency', reporting_frequency_chs, true)
    reporting_frequency.setDisplayName("Reporting Frequency.")
    reporting_frequency.setDefaultValue("Hourly")
    args << reporting_frequency 
	
    return args
  end

  # define what happens when the measure is run
  def run(runner, user_arguments)
    super(runner, user_arguments)

    # use the built-in error checking 
    if !runner.validateUserArguments(arguments(), user_arguments)
      return false
    end
	
    #assign the user inputs to variables
    variable_name = runner.getStringArgumentValue("variable_name",user_arguments)
    reporting_frequency = runner.getStringArgumentValue("reporting_frequency",user_arguments) 

	
    #check the user_name for reasonableness
    if variable_name == ""
      runner.registerError("No variable name was entered.")
      return false
    end
	
    # get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError("Cannot find last model.")
      return false
    end
    model = model.get

    sqlFile = runner.lastEnergyPlusSqlFile
    if sqlFile.empty?
      runner.registerError("Cannot find last sql file.")
      return false
    end
    sqlFile = sqlFile.get
    model.setSqlFile(sqlFile)
	
    # get the weather file run period (as opposed to design day run period)
    ann_env_pd = nil
    sqlFile.availableEnvPeriods.each do |env_pd|
      env_type = sqlFile.environmentType(env_pd)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new("WeatherRunPeriod")
          ann_env_pd = env_pd
          break
        end
      end
    end

    variable_names = sqlFile.availableVariableNames(ann_env_pd, reporting_frequency)
    if !variable_names.include? "#{variable_name}"	  
      runner.registerError("#{variable_name} is not in sqlFile.  Please add an AddOutputVariable reporting measure with this variable and run again.")
    else		
      headers = ["#{reporting_frequency}"]
      output_timeseries = {}
      key_values = sqlFile.availableKeyValues(ann_env_pd, reporting_frequency, variable_name.to_s)
      
      if key_values.size == 0
         runner.registerError("Timeseries for #{variable_name} did not have any key values. No timeseries available.")
      end
      
      key_values.each do |key_value|
        timeseries = sqlFile.timeSeries(ann_env_pd, reporting_frequency, variable_name.to_s, key_value.to_s)
        if !timeseries.empty?
        timeseries = timeseries.get
        units = timeseries.units
        headers << "#{key_value.to_s}:#{variable_name.to_s}[#{units}]"
        output_timeseries[headers[-1]] = timeseries
        else 
        runner.registerWarning("Timeseries for #{key_value} #{variable_name} is empty.")
        end	  
      end
      csv_array = []
      csv_array << headers
      date_times = output_timeseries[output_timeseries.keys[0]].dateTimes
      
      values = {}
      for key in output_timeseries.keys
        values[key] = output_timeseries[key].values
      end
      
      num_times = date_times.size - 1
      for i in 0..num_times
        date_time = date_times[i]
        row = []
        row << date_time
        for key in headers[1..-1]
        value = values[key][i]
        row << value
        end
        csv_array << row
      end

      File.open("./report_#{variable_name.delete(' ')}_#{reporting_frequency.delete(' ')}.csv", 'wb') do |file|
        csv_array.each do |elem|
        file.puts elem.join(',')
        end
      end
      
      runner.registerInfo("Output file written to #{File.expand_path('.')}")
    
    end
	
    # close the sql file
    sqlFile.close()

    return true
 
  end

end

# register the measure to be used by the application
ExportVariabletoCSV.new.registerWithApplication
