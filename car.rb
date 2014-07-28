module ParkingDO

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
			return @regNum + '	'+ @color
		end
	end

end