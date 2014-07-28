#! /usr/bin/ruby

require_relative 'parking_lot'
require_relative 'parking_commands'

class ParkingSystem
	@parkingLot = nil

	def execCommand(command)
			if(@parkingLot.nil?)
				begin
					@parkingLot = ParkingDO::ParkingLot.create(command)
					@parkingLot.addCommand(ParkingCommand::Park.new(@parkingLot))
					@parkingLot.addCommand(ParkingCommand::Status.new(@parkingLot))
					@parkingLot.addCommand(ParkingCommand::Leave.new(@parkingLot))
					@parkingLot.addCommand(ParkingCommand::SlotNumsForColor.new(@parkingLot))
					@parkingLot.addCommand(ParkingCommand::RegNumForSlotNum.new(@parkingLot))
					@parkingLot.addCommand(ParkingCommand::RegNumsForColor.new(@parkingLot))
				rescue Exception => error
					puts error.message
					puts 'Please create a parking lot with more than zero slots'
				end
			else
				@parkingLot.executeCommand(command)
			end
	end

end 

p = ParkingSystem.new
if(ARGV.length == 0 )
	while(true)
		command = gets()
		p.execCommand(command)
	end
else
	IO.foreach(ARGV[0]){|line| p.execCommand(line.strip())}
end
