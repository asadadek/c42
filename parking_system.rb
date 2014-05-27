#! /usr/bin/ruby

class Slot
	attr_reader :num
	attr_reader :car
	def initialize(num,car)
		@num = num
		@car = car
	end
end

class ParkingLot

	def initialize(capacity)
		@capacity = capacity.to_i
		@size = 0
		@slots = Array.new(@capacity)
		@commands = Array.new
	end	

	def allottedSlots()
		return @slots.compact()
	end

	def addCommand(command)
		@commands.push(command)
	end

	def executeCommand(commandStr)
		for command in @commands
			if(command.execute(commandStr))
				# Once a command is executed, we exit.
				return true
			end
		end
		puts('Unknown command: '+ commandStr)
		return false
	end


	def park(car)
		if(full?)
			return nil
		end
		for i in 0..@slots.length
			if(@slots.at(i).nil?)
				slot = Slot.new(i+1,car)
				@slots[i] = slot
				@size += 1
				return slot
			end
		end
	end

	def isParked(car)
		@slots.select { |slot| !slot.nil? && slot.car == car}.length == 1
	end


	def full?()
		@size == @capacity
	end

	def leave(slotNum)
		if(slotNum > @capacity)
			raise 'Slot number '+ slotNum.to_s+" does not exist"
		end
		if(@slots[slotNum - 1].nil?)
			raise 'Slot number '+ slotNum.to_s+" is empty"
		else
			@slots[slotNum - 1] = nil
			@size -= 1
			puts('Slot number '+ slotNum.to_s+" is free")
		end	
	end

	#Provides the status of the whole parking lot.
	def status()
		puts("Slot No.	Registration No	Colour")
		@slots.each { |slot| 
			if( !slot.nil?) 
				puts(slot.num.to_s + '	' + slot.car.regNum + '	' + slot.car.color) 
			end
		}
	end

	def query(queryFunc)	
		@slots.map(&queryFunc)
	end 
end

class Car
	attr_reader :color
	attr_reader :regNum

	def initialize(regNum,color)
		@regNum = regNum
		@color = color
	end

	def ==(o)
		self.color == o.color && self.regNum == o.regNum
	end

	def to_s()
		return @color + " car with registration number: "+@regNum 
	end
end

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
		car = Car.new(matchData[1],matchData[2])
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
		@parkingLot.status()
	end
end

class SlotNumForColorQuery < Command

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
		@parkingLot.allottedSlots.select { |slot| slot.car.color == matchData[1] }.map{|slot| slot.num}.join(",")
	end	

end

class CarRegNumQuery < Command

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
		slots = @parkingLot.allottedSlots.select { |slot| slot.car.regNum == matchData[1] }
		if (slots.length == 1)
			puts(slots.at(0).num)
		else
			puts('Not found')
		end		
	end	

end

class RegNumForColorQuery < Command

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
		@parkingLot.allottedSlots.select { |slot| slot.car.color == matchData[1] }.map{ |slot| slot.car.regNum}.join(",")
	end	

end

class ParkingLotFactory

	def self.makeParkingLot(command)
		pattern = '^create_parking_lot\s+(\d+)$'
		md = command.match(pattern)
		puts(md[1])
		if(md.nil? || md[1].nil?)
			raise 'Can process only parking lot creation'
		end 
		numSlots = md[1].strip.to_i
		if(numSlots > 0)
			p =  ParkingLot.new(numSlots)
			p.addCommand(Park.new(p))
			p.addCommand(Status.new(p))
			p.addCommand(Leave.new(p))
			p.addCommand(SlotNumForColorQuery.new(p))
			p.addCommand(CarRegNumQuery.new(p))
			p.addCommand(RegNumForColorQuery.new(p))
			puts('Created a parking lot with ' +numSlots.to_s+' slots')
			return p
		else
			raise 'Will not create a parking lot with less than 1 slot'
		end
		
	end 
end 

class ParkingSystem
	@parkingLot = nil

	def execCommand(command)
			if(@parkingLot.nil?)
				begin
					@parkingLot = ParkingLotFactory.makeParkingLot(command)
				rescue
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
