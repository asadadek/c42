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
end