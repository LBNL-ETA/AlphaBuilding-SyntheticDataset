# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class AddDemandControlledVentilation < OpenStudio::Measure::ModelMeasure
  # Standard space types for office rooms
  @@v_office_space_types = [
    'WholeBuilding - Sm Office',
    'WholeBuilding - Md Office',
    'WholeBuilding - Lg Office',
    'Office',
    'ClosedOffice',
    'OpenOffice',
    'SmallOffice - ClosedOffice',
    'SmallOffice - OpenOffice',
    'MediumOffice - ClosedOffice',
    'MediumOffice - OpenOffice',
    'LargeOffice - ClosedOffice',
    'LargeOffice - OpenOffice'
  ]
  # Standard space types for meeting rooms
  @@v_conference_space_types = [
    'Conference',
    'SmallOffice - Conference',
    'MediumOffice - Conference',
    'MediumOffice - Classroom',
    'LargeOffice - Conference'
  ]

  @@oa_per_person_office_default = 0.0025
  @@oa_per_area_office_default = 0.0003
  @@oa_per_person_conference_default = 0.0025
  @@oa_per_area_conference_default = 0.0003

  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Add Demand Controlled Ventilation'
  end

  # human readable description
  def description
    return 'Replace this text with an explanation of what the measure does in terms that can be understood by a general building professional audience (building owners, architects, engineers, contractors, etc.).  This description will be used to create reports aimed at convincing the owner and/or design team to implement the measure in the actual building design.  For this reason, the description may include details about how the measure would be implemented, along with explanations of qualitative benefits associated with the measure.  It is good practice to include citations in the measure if the description is taken from a known source or if specific benefits are listed.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Replace this text with an explanation for the energy modeler specifically.  It should explain how the measure is modeled, including any requirements about how the baseline model must be set up, major assumptions, citations of references to applicable modeling resources, etc.  The energy modeler should be able to read this description and understand what changes the measure is making to the model and why these changes are being made.  Because the Modeler Description is written for an expert audience, using common abbreviations for brevity is good practice.'
  end

  def create_design_spec_oa(model, oa_flow_per_person, oa_flow_per_area)
    oa_design_spec = OpenStudio::Model::DesignSpecificationOutdoorAir.new(model)
    oa_design_spec.setOutdoorAirMethod('Sum')
    oa_design_spec.setOutdoorAirFlowperPerson(oa_flow_per_person)
    oa_design_spec.setOutdoorAirFlowperFloorArea(oa_flow_per_area)
    return oa_design_spec
  end


  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    v_space_types = model.getSpaceTypes

    v_space_types.each do |space_type|
      if @@v_office_space_types.include? space_type.standardsSpaceType.to_s
        oa_per_person_office = OpenStudio::Measure::OSArgument.makeDoubleArgument('oa_per_person_office', true)
        oa_per_person_office.setDisplayName('Office outdoor air flow rate per person [m3/(s*person)]')
        oa_per_person_office.setDescription('This value will be used in the mechanical ventilation calculation with DCV.')
        oa_per_person_office.setDefaultValue(@@oa_per_person_office_default)

        oa_per_area_office = OpenStudio::Measure::OSArgument.makeDoubleArgument('oa_per_area_office', true)
        oa_per_area_office.setDisplayName('Office outdoor air flow rate per floor area [m3/(s*m2)]')
        oa_per_area_office.setDescription('This value will be used in the mechanical ventilation calculation with DCV.')
        oa_per_area_office.setDefaultValue(@@oa_per_area_office_default)

        args << oa_per_person_office
        args << oa_per_area_office

      elsif @@v_conference_space_types.include? space_type.standardsSpaceType.to_s
        oa_per_person_conference = OpenStudio::Measure::OSArgument.makeDoubleArgument('oa_per_person_conference', true)
        oa_per_person_conference.setDisplayName('Conference outdoor air flow rate per person [m3/(s*person)]')
        oa_per_person_conference.setDescription('This value will be used in the mechanical ventilation calculation with DCV.')
        oa_per_person_conference.setDefaultValue(@@oa_per_person_conference_default)

        oa_per_area_conference = OpenStudio::Measure::OSArgument.makeDoubleArgument('oa_per_area_conference', true)
        oa_per_area_conference.setDisplayName('Conference outdoor air flow rate per floor area [m3/(s*m2)]')
        oa_per_area_conference.setDescription('This value will be used in the mechanical ventilation calculation with DCV.')
        oa_per_area_conference.setDefaultValue(@@oa_per_area_conference_default)

        args << oa_per_person_conference
        args << oa_per_area_conference
      end
    end
    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    oa_per_person_office = @@oa_per_person_office_default
    oa_per_area_office = @@oa_per_area_office_default
    oa_per_person_conference = @@oa_per_person_conference_default
    oa_per_area_conference = @@oa_per_area_conference_default
    v_space_types = model.getSpaceTypes
    v_space_types.each do |space_type|
      if @@v_office_space_types.include? space_type.standardsSpaceType.to_s
        oa_per_person_office = runner.getDoubleArgumentValue('oa_per_person_office', user_arguments)
        oa_per_area_office = runner.getDoubleArgumentValue('oa_per_area_office', user_arguments)
        # check the arguments for reasonableness
        if oa_per_person_office.nan?
          runner.registerError('Office outdoor air flow rate per person was missing.')
          return false
        end
        if oa_per_area_office.nan?
          runner.registerError('Office outdoor air flow rate per person was missing.')
          return false
        end
      elsif @@v_conference_space_types.include? space_type.standardsSpaceType.to_s
        oa_per_person_conference = runner.getDoubleArgumentValue('oa_per_person_conference', user_arguments)
        oa_per_area_conference = runner.getDoubleArgumentValue('oa_per_area_conference', user_arguments)
        if oa_per_person_conference.nan?
          runner.registerError('Conference outdoor air flow rate per person was missing.')
          return false
        end
        if oa_per_area_conference.nan?
          runner.registerError('Conference outdoor air flow rate per person was missing.')
          return false
        end
      end
    end

    # report initial condition of model
    runner.registerInitialCondition("Measure starts.")

    # Add DesignSpecificationOutdoorAir to spaces
    v_spaces = model.getSpaces
    v_spaces.each do |space|
      if @@v_office_space_types.include? space.spaceType.get.standardsSpaceType.to_s
        oa_design_spec = create_design_spec_oa(model, oa_per_person_office, oa_per_area_office)
        space.setDesignSpecificationOutdoorAir(oa_design_spec)
        runner.registerInfo("Created new design specification outdoor air for: #{space.name}.")
      elsif @@v_conference_space_types.include? space.spaceType.get.standardsSpaceType.to_s
        oa_design_spec = create_design_spec_oa(model, oa_per_person_conference, oa_per_area_conference)
        space.setDesignSpecificationOutdoorAir(oa_design_spec)
        runner.registerInfo("Created new design specification outdoor air for: #{space.name}.")
      end
    end

    # Enbable DCV
    v_OA_controllers = model.getControllerMechanicalVentilations
    v_OA_controllers.each do |oa_controller|
      runner.registerInfo("DCV for controller: #{oa_controller.name} was enabled.")
      oa_controller.setDemandControlledVentilation(true)
    end

    # puts v_spaces

    # # report final condition of model
    runner.registerFinalCondition("New DesignSpecificationOutdoorAir objects are added, DCV are enabled.")

    return true
  end
end

# register the measure to be used by the application
AddDemandControlledVentilation.new.registerWithApplication
