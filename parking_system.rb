#! /usr/bin/ruby

class ParkingLot

	def initialize(capacity)
		@capacity = capacity.to_i
		@size = 0
		@slots = Array.new(@capacity)
	end	

	def park(car)
		if(full?)
			return -1
		end
		for i in 0..@slots.length
			if(@slots.at(i).nil?)
				@slots[i] = car
				@size += 1
				return i+1
			end
		end
	end

	def isParked(car)
		@slots.include?(car)
	end

	def slotNum(car)
		@slots.index(car)+1
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

	def status()
		puts("Slot No.	Registration No	Colour")
		for i in 0..@slots.length
			if(!@slots[i].nil?)
				puts((i+1).to_s+'	'+@slots[i].regNum+'	'+@slots[i].color)
			end
		end
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

class ParkingSystem

	def initialize( parkingSystem = self)
		@commands = Array.new
		@parkingLot = ParkingLot.new(0)
	end

	def addCommand(command)
		@commands.push(command)
	end

	def executeCommand(commandStr)
		for command in @commands
			if(command.execute(commandStr))
				return true
			end
		end
		puts('Unknown command: '+ commandStr)
		return false
	end

	def createParkingLot(size)
		@parkingLot = ParkingLot.new(size)	
	end


	def canParkMore?()
		!@parkingLot.full?
	end 

	def park(car)
		return @parkingLot.park(car)
	end

	def isParked(car)
		@parkingLot.isParked(car)
	end

	def slotNum(car)
		@parkingLot.slotNum(car)
	end

	def leave(slotNum)
		@parkingLot.leave(slotNum)
	end

	def status()
		@parkingLot.status()
	end

	def query(queryFunc)
		@parkingLot.query(queryFunc)
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

class CreateParkingLot < Command

	def initialize(parkingSystem)
		@parkingSystem = parkingSystem
	end


	def pattern()
		'^create_parking_lot (\d+)$'
	end

	def canProcess(matchData) 
		!(matchData.nil? || matchData[1].nil?)
	end 

	def process(matchData)
		numSlots = matchData[1].strip.to_i
		if(numSlots > 0)
			puts('Created a parking lot with ' +numSlots.to_s+' slots')
			@parkingSystem.createParkingLot(matchData[1].strip)
		else
			raise 'Will not create a parking lot with less than 1 slot'
		end
	end
end	

class Park < Command
	def initialize(parkingSystem)
		@parkingSystem = parkingSystem
	end


	def pattern()
		 '^park\s+(.+)\s+(.+)$'
	end

	def canProcess(matchData) 
		!(matchData.nil? || matchData[1].nil? || matchData[2].nil?)
	end 

	def process(matchData)
		car = Car.new(matchData[1],matchData[2])
		if(@parkingSystem.isParked(car))
			#What to do? Raise error? Ignore silently?
			raise car.to_s + ' is already parked with us. Shall I call the cops?'
		end	
		slotNum = @parkingSystem.park(car)
		if(slotNum > 0)
			puts('Allocated slot number: '+ slotNum.to_s)
		else
			puts('Sorry, parking lot is full')
		end	
	end
end

class Leave < Command
	def initialize(parkingSystem)
		@parkingSystem = parkingSystem
	end
	
	def pattern()
		 '^leave\s(\d+)$'
	end


	def canProcess(matchData) 
		!(matchData.nil? || matchData[1].nil? )
	end

	def process(matchData)
		slotNum = matchData[1].to_i
		@parkingSystem.leave(slotNum)
	end
end

class Status < Command
	def initialize(parkingSystem)
		@parkingSystem = parkingSystem
	end


	def pattern()
		 '^status$'
	end


	def process(matchData)
		@parkingSystem.status()
	end
end

class SlotNumForColorQuery < Command

	def initialize(parkingSystem)
		@parkingSystem = parkingSystem
	end

	def pattern()
		'^slot_numbers_for_cars_with_colour\s(.+)$'
	end

	def canProcess(matchData)
		!(matchData.nil? || matchData[1].nil?)
	end 

	def process(matchData)
		cars = @parkingSystem.query(Proc.new{|car| if (!car.nil? && car.color == matchData[1]) then car end}).compact()
		puts(cars.map(&Proc.new{|car| @parkingSystem.slotNum(car)}).join(","))
	end	

end

class CarRegNumQuery < Command

	def initialize(parkingSystem)
		@parkingSystem = parkingSystem
	end

	def pattern()
		'^slot_number_for_registration_number\s(.+)$'
	end

	def canProcess(matchData)
		!(matchData.nil? || matchData[1].nil?)
	end 

	def process(matchData)
		cars = @parkingSystem.query(Proc.new{|car| if (!car.nil? && car.regNum == matchData[1]) then car end}).compact()
		if (cars.length == 1)
			puts(@parkingSystem.slotNum(cars.at(0)))
		else
			puts('Not found')
		end		
	end	

end

class RegNumForColorQuery < Command

	def initialize(parkingSystem)
		@parkingSystem = parkingSystem
	end

	def pattern()
		'^registration_numbers_for_cars_with_colour\s+(.+)$'
	end

	def canProcess(matchData)
		!(matchData.nil? || matchData[1].nil?)
	end 

	def process(matchData)
		cars = @parkingSystem.query(Proc.new{|car| if (!car.nil? && car.color == matchData[1]) then car.regNum end}).compact()
		if(cars.length > 0 )
			puts(cars.join(","))
		else
			puts('Not found')
		end
	end	

end
p = ParkingSystem.new
p.addCommand(Park.new(p))
p.addCommand(CreateParkingLot.new(p))
p.addCommand(Status.new(p))
p.addCommand(Leave.new(p))
p.addCommand(SlotNumForColorQuery.new(p))
p.addCommand(CarRegNumQuery.new(p))
p.addCommand(RegNumForColorQuery.new(p))

if(ARGV.length == 0 )
	while(true)
		command = gets()
		p.executeCommand(command)
	end
else
	IO.foreach(ARGV[0]){|line| p.executeCommand(line.strip())}
end
