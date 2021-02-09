require 'erb'
require 'csv'

#start the measure
class ExportMetertoCSV < OpenStudio::Ruleset::ReportingUserScript

  # human readable name
  def name
    return "ExportMetertoCSV"
  end

  # human readable description
  def description
    return "Exports an OutputMeter specified in the AddOutputMeter OpenStudio measure to a csv file."
  end

  # human readable description of modeling approach
  def modeler_description
    return "This measure searches for the OutputMeter name in the eplusout sql file and saves it to a csv file."
  end

  # define the arguments that the user will input
  def arguments()
    args = OpenStudio::Ruleset::OSArgumentVector.new

    #make an argument for the variable name
    meter_name = OpenStudio::Ruleset::OSArgument::makeStringArgument("meter_name",true)
    meter_name.setDisplayName("Enter Meter Name.")
    args << meter_name
	
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
    meter_name = runner.getStringArgumentValue("meter_name",user_arguments)
    reporting_frequency = runner.getStringArgumentValue("reporting_frequency",user_arguments) 

    #check the user_name for reasonableness
    if meter_name == ""
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

    sql = runner.lastEnergyPlusSqlFile
    if sql.empty?
      runner.registerError("Cannot find last sql file.")
      return false
    end
    sql = sql.get
    model.setSqlFile(sql)
	
    # get the weather file run period (as opposed to design day run period)
    ann_env_pd = nil
    sql.availableEnvPeriods.each do |env_pd|
      env_type = sql.environmentType(env_pd)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new("WeatherRunPeriod")
          ann_env_pd = env_pd
          break
        end
      end
    end

    meter_names = sql.availableVariableNames(ann_env_pd, reporting_frequency)
    if !meter_names.include? "#{meter_name}"
      runner.registerError("Meter #{meter_name} is not in the sql file.  Please add the associated Output:Meter object.  You can do this with the AddMeter reporting measure available on BCL.")
    end
      
    headers = ["#{reporting_frequency}"]
    output_timeseries = {}

    timeseries = sql.timeSeries(ann_env_pd, reporting_frequency, meter_name.to_s,"")
    if !timeseries.empty?
      timeseries = timeseries.get
      units = timeseries.units
      headers << "#{meter_name.to_s}[#{units}]"
      output_timeseries[headers[-1]] = timeseries
    else 
      runner.registerWarning("Timeseries data is not available for #{meter_name} with frequency #{reporting_frequency}.  Did you remember to include the associated Output:Meter request?")
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

    File.open("./report_#{meter_name.delete(' ').delete(':')}_#{reporting_frequency.delete(' ')}.csv", 'wb') do |file|
      csv_array.each do |elem|
      file.puts elem.join(',')
      end
    end

    # close the sql file
    sql.close()

    return true
 
  end

end

# register the measure to be used by the application
ExportMetertoCSV.new.registerWithApplication
