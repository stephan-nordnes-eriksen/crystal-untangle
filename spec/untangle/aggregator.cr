require "./../spec_helper"

describe Aggregator do
	# TODO: Write tests

	it "self.subscribe (message_type, callback : Proc) exists" do
		# pp callback.class
		a = false
		Aggregator.subscribe("test") do |data|
			a = true
			return data
		end
		#sleep 10.0
		Aggregator.publish("test", "true")
		a.should eq true
	end
	# it "self.unSubscribe (message_type, callback : Proc) exists" do
	# 	Aggregator.unSubscribe("test") do |data|

	# 	end
	# end
	# it "self.respond (message_type, callback : Proc) exists" do
	# 	Aggregator.respond("test") do |data|

	# 	end
	# end
	# it "self.unRespond (message_type, callback : Proc) exists" do
	# 	Aggregator.unRespond("test") do |data|

	# 	end
	# end
	# it "self.publish (message_type, data) exists" do
	# 	Aggregator.publish("test", "data")
	# end
	# it "self.request(*arguments) exists" do
	# 	Aggregator.request("test", "data")
	# end
	# it "self.helpers exists" do
	# 	Aggregator.helpers()
	# end
	# it "self.subscribeAll (callback : Proc) exists" do
	# 	Aggregator.subscribeAll() do |message_type, data|

	# 	end
	# end
	# it "self.unSubscribeAll (callback : Proc) exists" do
	# 	Aggregator.unSubscribeAll() do |data|

	# 	end
	# end
	# it "self.reroute (from_type, to_type, callback = Proc(String).new{|e| return e}) exists" do
	# 	Aggregator.reroute("test", "testnew") do |data|

	# 	end
	# 	Aggregator.reroute("test", "testnew2")
	# end
	# it "self.un_reroute (from_type, to_type) exists" do
	# 	Aggregator.un_reroute("test", "testnew")
	# end
	# it "self.resetAll (data) exists" do
	# 	Aggregator.resetAll("test") #Nothing happens
	# 	Aggregator.resetAll("HARD") #something happens
	# end

	# it "adds methods to the string class" do
	# 	"".subscribe do |data|

	# 	end
	# 	"".unSubscribe do |data|

	# 	end
	# 	"".respond do |data|

	# 	end
	# 	"".unRespond do |data|

	# 	end
	# 	"".publish("data")
	# 	"".request("data")
	# 	"".reroute("new route") do |data|

	# 	end
	# 	"".un_reroute("new route")
	# end
end
