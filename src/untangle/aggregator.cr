class Aggregator
	@@subscribers = Hash(String, Array(String ->)).new {|h, k| h[k] = [] of String -> }
	# @@subscribers = Hash(String, Array(Proc(String))).new# {} of String => Array(Proc(String))
	@@subscribers_all = Array(String, String ->).new
	# @@responders = {} of String => Hash(String, Proc(String))
	@@responders = Hash(String, (String ->)).new
	# @@responders = Hash(String, String ->).new This does not work. why? #bug in crystal?
	@@reroutes = {} of String => Proc(String)

	def self.subscribe (message_type, &callback : String ->)
		@@subscribers[message_type] << callback
	end
	def self.unSubscribe (message_type, &callback : String ->)
		@@subscribers[message_type].delete(callback) if @@subscribers[message_type]
	end
	def self.respond (message_type, &callback : String ->)
		@@responders[message_type] = callback
	end
	def self.unRespond (message_type, &callback : String ->)
		@@responders.delete(message_type) #if @@responders.has_key?(message_type) #I don't think we bother with checking even.
	end
	def self.publish (message_type, data)
		# @@subscribers_all.each &.call(message_type, data)
		@@subscribers_all.each do |callback|
			spawn do
				callback.call(message_type, data)
			end
		end
		if @@reroutes[message_type]
			@@reroutes.each do |to_type, callback| 
				if callback.class == Proc
					Untangle.publish(to_type, callback.call(data))
				else
					Untangle.publish(to_type, data)
				end
			end
		end
	end
	def self.request(message_type, arguments)
		# message_type = arguments[0]
		# the_args = arguments
		# if arguments.class == String
		# 	message_type = arguments
		# 	the_args = [arguments]
		# end
		# if arguments.size <= 0
		# 	arguments = {nil}
		# end

		#Splatting not yet supported
		return @@responders[message_type].call(arguments) if @@responders[message_type]
		return nil
	end
	def self.helpers
		# struct String
		# 	def subscribe (data)
		# 		Untangle.subscribe(this.toString(), data)
		# 	end
		# 	def unSubscribe (data)
		# 		Untangle.unSubscribe(this.toString(), data)
		# 	end
		# 	def respond (data)
		# 		Untangle.respond(this.toString(), data)
		# 	end
		# 	def unRespond (data)
		# 		Untangle.unRespond(this.toString(), data)
		# 	end
		# 	def publish (data)
		# 		Untangle.publish(this.toString(), data)
		# 	end
		# 	def request ()
		# 		Untangle.request.apply(this, arguments)
		# 	end
		# 	def reroute (data, &callback : String ->)
		# 		Untangle.reroute(this.toString(), data, callback)
		# 	end
		# 	def un_reroute (data)
		# 		Untangle.un_reroute(this.toString(), data)
		# 	end
		# end
	end
	def self.subscribeAll (&callback : (String, String ->))
		@@subscribers_all << callback
	end
	def self.unSubscribeAll (&callback : (String, String ->))
		@@subscribers_all.delete(callback)
	end
	def self.reroute (from_type, to_type)
		self.reroute(from_type, to_type) do |data|
			return data
		end
	end
	def self.reroute (from_type, to_type, &callback : String ->)
		@@reroutes[from_type][to_type] = callback
	end
	def self.un_reroute (from_type, to_type)
		@@reroutes[from_type].delete(to_type) if @@reroutes[from_type]
	end
	def self.resetAll (data)
		if data == "HARD"
			@@subscribers.clear()
			@@subscribers_all.clear()
			@@responders.clear()
			@@reroutes.clear()
		end
	end
end

class String
	def subscribe (&callback : String ->)
		Aggregator.subscribe(self, &callback)
	end
	def unSubscribe (&callback : String ->)
		Aggregator.unSubscribe(self, &callback)
	end
	def respond (&callback : String ->)
		Aggregator.respond(self, &callback)
	end
	def unRespond (&callback : String ->)
		Aggregator.unRespond(self, &callback)
	end
	def publish (data)
		Aggregator.publish(self, data)
	end
	def request (data)
		Aggregator.request(self, data)
	end
	def reroute (data, &callback : String ->)
		Aggregator.reroute(self, data, &callback)
	end
	def un_reroute (data)
		Aggregator.un_reroute(self, data)
	end
end