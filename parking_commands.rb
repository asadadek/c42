require_relative 'car'
require_relative 'slot'
module ParkingCommand
	class Command
		MISSING_METHOD = 'System error: Missing method'
		def execute(command)
			md = command.match(pattern())
			if(canProcess(md))
				process(md)
				return true
			else
				return false	
			end	
		end

		def canProcess(matchData)  !matchData.nil? end
		def pattern() raise MISSING_METHOD end
		def process(matchData) raise MISSING_METHOD end
	end 



	class Park < Command
		def initialize(parkingLot)
			@parkingLot = parkingLot
		end


		def pattern()
			 '^park\s+(.+)\s+(.+)$'
		end

		def canProcess(matchData) 
			!(matchData.nil? || matchData[1].nil? || matchData[2].nil?)
		end 

		def process(matchData)
			car = ParkingDO::Car.new(matchData[1],matchData[2])
			if(@parkingLot.isParked(car))
				#What to do? Raise error? Ignore silently?
				raise car.to_s + ' is already parked with us. Shall I call the cops?'
			end	
			slot = @parkingLot.park(car)
			if(!slot.nil?)
				puts('Allocated slot number: '+ slot.num.to_s)
			else
				puts('Sorry, parking lot is full')
			end	
		end
	end

	class Leave < Command
		def initialize(parkingLot)
			@parkingLot = parkingLot
		end
		
		def pattern()
			 '^leave\s(\d+)$'
		end


		def canProcess(matchData) 
			!(matchData.nil? || matchData[1].nil? )
		end

		def process(matchData)
			slotNum = matchData[1].to_i
			@parkingLot.leave(slotNum)
		end
	end

	class Status < Command
		def initialize(parkingLot)
			@parkingLot = parkingLot
		end


		def pattern()
			 '^status$'
		end


		def process(matchData)
			puts(@parkingLot.to_s)
		end
	end

	class SlotNumsForColor < Command

		def initialize(parkingLot)
			@parkingLot = parkingLot
		end

		def pattern()
			'^slot_numbers_for_cars_with_colour\s(.+)$'
		end

		def canProcess(matchData)
			!(matchData.nil? || matchData[1].nil?)
		end 

		def process(matchData)
			@parkingLot.allottedSlots.select { |slot| slot.car.color?(matchData[1]) }.map{|slot| slot.num}.join(",")
		end	

	end

	class RegNumForSlotNum < Command

		def initialize(parkingLot)
			@parkingLot = parkingLot
		end

		def pattern()
			'^slot_number_for_registration_number\s(.+)$'
		end

		def canProcess(matchData)
			!(matchData.nil? || matchData[1].nil?)
		end 

		def process(matchData)
			slots = @parkingLot.allottedSlots.select { |slot| 
				slot.car.regNum?(matchData[1])
				 }
			if (slots.length == 1)
				puts(slots.at(0).num)
			else
				puts('Not found')
			end		
		end	

	end

	class RegNumsForColor < Command

		def initialize(parkingLot)
			@parkingLot = parkingLot
		end

		def pattern()
			'^registration_numbers_for_cars_with_colour\s+(.+)$'
		end

		def canProcess(matchData)
			!(matchData.nil? || matchData[1].nil?)
		end 

		def process(matchData)
			@parkingLot.allottedSlots.select { |slot| 
				slot.car.color?  matchData[1] 
				}.map{ |slot| slot.car.regNum}.join(",")
		end	

	end

end