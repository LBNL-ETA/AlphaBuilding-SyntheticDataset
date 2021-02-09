require 'openstudio'

require 'openstudio/ruleset/ShowRunnerOutput'

require "#{File.dirname(__FILE__)}/../measure.rb"

require 'minitest/autorun'

class AddOutputVariable_Test < MiniTest::Unit::TestCase

  def test_AddOutputVariable_GoodInput

    # create an instance of the measure
    measure = AddOutputVariable.new

    # create an instance of a runner
    runner = OpenStudio::Ruleset::OSRunner.new

    # make an empty model
    model = OpenStudio::Model::Model.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)

    # set argument values to good values and run the measure on model with spaces
    argument_map = OpenStudio::Ruleset::OSArgumentMap.new
    variable_name = arguments[0].clone
    assert(variable_name.setValue("JustATest"))
    argument_map["variable_name"] = variable_name
    reporting_frequency = arguments[1].clone
    assert(reporting_frequency.setValue("hourly"))
    argument_map["reporting_frequency"] = reporting_frequency
    key_value = arguments[2].clone
    assert(key_value.setValue("Test"))
    argument_map["key_value"] = key_value
    measure.run(model, runner, argument_map)
    result = runner.result
    show_output(result)
    assert(result.value.valueName == "Success")
    assert(result.warnings.size == 0)
    #assert(result.info.size == 1)

  end

end
