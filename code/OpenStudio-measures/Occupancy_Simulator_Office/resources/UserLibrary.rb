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

require "csv"

class UserLibrary
  # This class is used to store user pre-defined library
  def initialize(csvFile)
    dt = CSV.table(csvFile,:headers=>false)
    # SpaceType 1
    @Office_t1_name = dt[1][0]
    @Office_t1_OccupancyDensity = dt[2][1]
    @office_t1_OccupantPercentageManager = dt[3][1]
    @office_t1_OccupantPercentageAdminitrator = dt[4][1]
    @office_t1_OccupantPercentageRegularStaff = dt[5][1]
    @meetingRoom_t1_name = dt[6][0]
    @meetingRoom_t1_MinimumNumberOfMeetingPerDay = dt[7][1]
    @meetingRoom_t1_MaximumNumberOfMeetingPerDay = dt[8][1]
    @meetingRoom_t1_MinimumNumberOfPeoplePerMeeting = dt[9][1]
    @meetingRoom_t1_MaximumNumberOfPeoplePerMeeting = dt[10][1]
    @meetingRoom_t1_ProbabilityOf_30_minMeetings = dt[11][1]
    @meetingRoom_t1_ProbabilityOf_60_minMeetings = dt[12][1]
    @meetingRoom_t1_ProbabilityOf_90_minMeetings = dt[13][1]
    @meetingRoom_t1_ProbabilityOf_120_minMeetings = dt[14][1]
    # SpaceType 2
    @Office_t2_name = dt[1][2]
    @Office_t2_OccupancyDensity = dt[2][3]
    @office_t2_OccupantPercentageManager = dt[3][3]
    @office_t2_OccupantPercentageAdminitrator = dt[4][3]
    @office_t2_OccupantPercentageRegularStaff = dt[5][3]
    @meetingRoom_t2_name = dt[6][2]
    @meetingRoom_t2_MinimumNumberOfMeetingPerDay = dt[7][3]
    @meetingRoom_t2_MaximumNumberOfMeetingPerDay = dt[8][3]
    @meetingRoom_t2_MinimumNumberOfPeoplePerMeeting = dt[9][3]
    @meetingRoom_t2_MaximumNumberOfPeoplePerMeeting = dt[10][3]
    @meetingRoom_t2_ProbabilityOf_30_minMeetings = dt[11][3]
    @meetingRoom_t2_ProbabilityOf_60_minMeetings = dt[12][3]
    @meetingRoom_t2_ProbabilityOf_90_minMeetings = dt[13][3]
    @meetingRoom_t2_ProbabilityOf_120_minMeetings = dt[14][3]
    # SpaceType 3
    @Office_t3_name = dt[1][4]
    @Office_t3_OccupancyDensity = dt[2][5]
    @office_t3_OccupantPercentageManager = dt[3][5]
    @office_t3_OccupantPercentageAdminitrator = dt[4][5]
    @office_t3_OccupantPercentageRegularStaff = dt[5][5]
    @meetingRoom_t3_name = dt[6][4]
    @meetingRoom_t3_MinimumNumberOfMeetingPerDay = dt[7][5]
    @meetingRoom_t3_MaximumNumberOfMeetingPerDay = dt[8][5]
    @meetingRoom_t3_MinimumNumberOfPeoplePerMeeting = dt[9][5]
    @meetingRoom_t3_MaximumNumberOfPeoplePerMeeting = dt[10][5]
    @meetingRoom_t3_ProbabilityOf_30_minMeetings = dt[11][5]
    @meetingRoom_t3_ProbabilityOf_60_minMeetings = dt[12][5]
    @meetingRoom_t3_ProbabilityOf_90_minMeetings = dt[13][5]
    @meetingRoom_t3_ProbabilityOf_120_minMeetings = dt[14][5]
    # SpaceType 4
    @Office_t4_name = dt[1][6]
    @Office_t4_OccupancyDensity = dt[2][7]
    @office_t4_OccupantPercentageManager = dt[3][7]
    @office_t4_OccupantPercentageAdminitrator = dt[4][7]
    @office_t4_OccupantPercentageRegularStaff = dt[5][7]
    @meetingRoom_t4_name = dt[6][6]
    @meetingRoom_t4_MinimumNumberOfMeetingPerDay = dt[7][7]
    @meetingRoom_t4_MaximumNumberOfMeetingPerDay = dt[8][7]
    @meetingRoom_t4_MinimumNumberOfPeoplePerMeeting = dt[9][7]
    @meetingRoom_t4_MaximumNumberOfPeoplePerMeeting = dt[10][7]
    @meetingRoom_t4_ProbabilityOf_30_minMeetings = dt[11][7]
    @meetingRoom_t4_ProbabilityOf_60_minMeetings = dt[12][7]
    @meetingRoom_t4_ProbabilityOf_90_minMeetings = dt[13][7]
    @meetingRoom_t4_ProbabilityOf_120_minMeetings = dt[14][7]
    # SpaceType 5
    @Office_t5_name = dt[1][8]
    @Office_t5_OccupancyDensity = dt[2][9]
    @office_t5_OccupantPercentageManager = dt[3][9]
    @office_t5_OccupantPercentageAdminitrator = dt[4][9]
    @office_t5_OccupantPercentageRegularStaff = dt[5][9]
    @meetingRoom_t5_name = dt[6][8]
    @meetingRoom_t5_MinimumNumberOfMeetingPerDay = dt[7][9]
    @meetingRoom_t5_MaximumNumberOfMeetingPerDay = dt[8][9]
    @meetingRoom_t5_MinimumNumberOfPeoplePerMeeting = dt[9][9]
    @meetingRoom_t5_MaximumNumberOfPeoplePerMeeting = dt[10][9]
    @meetingRoom_t5_ProbabilityOf_30_minMeetings = dt[11][9]
    @meetingRoom_t5_ProbabilityOf_60_minMeetings = dt[12][9]
    @meetingRoom_t5_ProbabilityOf_90_minMeetings = dt[13][9]
    @meetingRoom_t5_ProbabilityOf_120_minMeetings = dt[14][9]
    # @OccupantBehaviorRules = dt[15][1]
    @managerTypicalArrivalTime = dt[16][1]
    @managerArrivalTimeVariation = dt[17][1]
    @managerTypicalDepartureTime = dt[18][1]
    @managerDepartureTimeVariation = dt[19][1]
    @managerTypicalShortTermLeaving = dt[20][1]
    @managerShortTermLeavingVariation = dt[21][1]
    @managerTypicalShortTermLeavingDuration = dt[22][1]
    @managerShortTermLeavingDurationVariation = dt[23][1]
    @managerPercentOfTimeInSpaceOwnOffice = dt[24][1]
    @managerAverageStayTimeOwnOffice = dt[25][1]
    @managerPercentOfTimeInSpaceOtherOffices = dt[26][1]
    @managerAverageStayTimeOtherOffices = dt[27][1]
    @managerPercentOfTimeInSpaceMeetingRooms = dt[28][1]
    @managerAverageStayTimeMeetingRooms = dt[29][1]
    @managerPercentOfTimeInSpaceAuxiliaryRooms = dt[30][1]
    @managerAverageStayTimeAuxiliaryRooms = dt[31][1]
    @managerPercentOfTimeInSpaceOutdoor = dt[32][1]
    @managerAverageStayTimeOutdoor = dt[33][1]
    @administratorTypicalArrivalTime = dt[34][1]
    @administratorArrivalTimeVariation = dt[35][1]
    @administratorTypicalDepartureTime = dt[36][1]
    @administratorDepartureTimeVariation = dt[37][1]
    @administratorTypicalShortTermLeaving = dt[38][1]
    @administratorShortTermLeavingVariation = dt[39][1]
    @administratorTypicalShortTermLeavingDuration = dt[40][1]
    @administratorShortTermLeavingDurationVariation = dt[41][1]
    @administratorPercentOfTimeInSpaceOwnOffice = dt[42][1]
    @administratorAverageStayTimeOwnOffice = dt[43][1]
    @administratorPercentOfTimeInSpaceOtherOffices = dt[44][1]
    @administratorAverageStayTimeOtherOffices = dt[45][1]
    @administratorPercentOfTimeInSpaceMeetingRooms = dt[46][1]
    @administratorAverageStayTimeMeetingRooms = dt[47][1]
    @administratorPercentOfTimeInSpaceAuxiliaryRooms = dt[48][1]
    @administratorAverageStayTimeAuxiliaryRooms = dt[49][1]
    @administratorPercentOfTimeInSpaceOutdoor = dt[50][1]
    @administratorAverageStayTimeOutdoor = dt[51][1]
    @regularStaffTypicalArrivalTime = dt[52][1]
    @regularStaffArrivalTimeVariation = dt[53][1]
    @regularStaffTypicalDepartureTime = dt[54][1]
    @regularStaffDepartureTimeVariation = dt[55][1]
    @regularStaffTypicalShortTermLeaving = dt[56][1]
    @regularStaffShortTermLeavingVariation = dt[57][1]
    @regularStaffTypicalShortTermLeavingDuration = dt[58][1]
    @regularStaffShortTermLeavingDurationVariation = dt[59][1]
    @regularStaffPercentOfTimeInSpaceOwnOffice = dt[60][1]
    @regularStaffAverageStayTimeOwnOffice = dt[61][1]
    @regularStaffPercentOfTimeInSpaceOtherOffices = dt[62][1]
    @regularStaffAverageStayTimeOtherOffices = dt[63][1]
    @regularStaffPercentOfTimeInSpaceMeetingRooms = dt[64][1]
    @regularStaffAverageStayTimeMeetingRooms = dt[65][1]
    @regularStaffPercentOfTimeInSpaceAuxiliaryRooms = dt[66][1]
    @regularStaffAverageStayTimeAuxiliaryRooms = dt[67][1]
    @regularStaffPercentOfTimeInSpaceOutdoor = dt[68][1]
    @regularStaffAverageStayTimeOutdoor = dt[69][1]
    @HolidayRules = dt[70][1]
    @usHolidayNewYearsDay = dt[71][1]
    @usHolidayMartinLutherKingJrDay = dt[72][1]
    @usHolidayGeorgeWashingtonsBirthday = dt[73][1]
    @usHolidayMemorialDay = dt[74][1]
    @usHolidayIndependenceDay = dt[75][1]
    @usHolidayLaborDay = dt[76][1]
    @usHolidayColumbusDay = dt[77][1]
    @usHolidayVeteransDay = dt[78][1]
    @usHolidayThanksgivingDay = dt[79][1]
    @usHolidayChristmasDay = dt[80][1]
    @customHolidayCustomHoliday_1 = dt[81][1]
    @customHolidayCustomHoliday_2 = dt[82][1]
    @customHolidayCustomHoliday_3 = dt[83][1]
    @customHolidayCustomHoliday_4 = dt[84][1]
    @customHolidayCustomHoliday_5 = dt[85][1]
    # Create getters for all instance variables
    create_getters
  end

  # Create getters for all instance variables
  def create_getters
    instance_variables.each do |v|
      define_singleton_method(v.to_s.tr('@','')) do
        instance_variable_get(v)
      end
    end
  end

end


# userLib = UserLibrary.new("library.csv")

# puts userLib.Office_t5_OccupancyDensity