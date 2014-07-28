#! /usr/bin/ruby
module ParkingDO
	class Slot
		attr_reader :num
		attr_reader :car
		def initialize(num,car)
			@num = num
			@car = car
		end

		def to_s()
			@num.to_s + '	' + @car.to_s
		end
	end

	class ParkingLot

		def self.create(command)
			pattern = '^create_parking_lot\s+(\d+)$'
			md = command.match(pattern)
			puts(md[1])
			if(md.nil? || md[1].nil?)
				raise 'Can process only parking lot creation'
			end 
			numSlots = md[1].strip.to_i
			if(numSlots > 0)
				p =  ParkingLot.new(numSlots)
				puts('Created a parking lot with ' +numSlots.to_s+' slots')
				return p
			else
				raise 'Will not create a parking lot with less than 1 slot'
			end
		end 

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
		def to_s()
			status = "Slot No.	Registration No	Colour\n"
			allottedSlots.each { |slot| 
				if( !slot.nil?) 
					status += slot.to_s + '\n'
				end
			}
		end
	 
	end

	class Car
		attr_reader :color
		attr_reader :regNum

		def initialize(regNum,color)
			@regNum = regNum
			@color = color
		end

		def ==(car)
			color?(car.color) && regNum?(car.regNum)
		end

		def color?(col)
			self.color.downcase == col.downcase
		end	

		def regNum?(regNum)
			self.regNum.downcase == regNum.downcase
		end

		def to_s()
			return @regNum + '	'+@color
		end
	end
end