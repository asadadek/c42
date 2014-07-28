#! /usr/bin/ruby

class A
	#attr_reader :x

	def initialize()
		@x = [1,2,3,4]
	end

	def x()
		@x.compact
	end

	def to_s()
		@x.to_s
	end
end


a = A.new
puts a
a.x.push(10)
puts a