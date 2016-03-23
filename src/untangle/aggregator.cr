class Aggregator
  @@subscribers = Hash(String, Array(String ->)).new { |h, k| h[k] = [] of String -> }
  @@subscribers_all = Array((String, String -> Void)).new
  @@responders = Hash(String, (String -> String)).new
  # @@reroutes = {} of String => Proc(String)
  @@reroutes = Hash(String, Array({String, (String -> String)})).new { |h, k| h[k] = Array({String, (String -> String)}).new }
  @@reroutes_request = Hash(String, Array({String, (String -> String)})).new { |h, k| h[k] = Array({String, (String -> String)}).new }

  def self.subscribe(message_type, &callback : String ->)
    @@subscribers[message_type] << callback
  end

  def self.unSubscribe(message_type, &callback : String ->)
    @@subscribers[message_type].delete(callback) if @@subscribers[message_type]
  end

  def self.respond(message_type, &callback : String -> String)
    @@responders[message_type] = callback
  end

  def self.unRespond(message_type)
    @@responders.delete(message_type)
  end

  def self.publish(message_type : String, data : String)
    @@subscribers_all.each do |callback|
      ch = Channel(String).new
      spawn do
        message_type = ch.receive
        data = ch.receive
        callback.call(message_type, data)
      end

      ch.send(message_type)
      ch.send(data)
    end

    @@subscribers[message_type].each do |callback|
      # future { callback.call(data) }
      ch = Channel(String).new
      spawn do
        callback.call(ch.receive)
      end
      ch.send(data)
    end

    @@reroutes[message_type].each do |tuple| # |to_type, callback|
      Aggregator.publish(tuple[0], tuple[1].call(data))
    end
  end

  def self.request(message_type)
    self.request(message_type, "")
  end

  def self.request(message_type, data : String | Nil)
    # Splatting not yet supported, maybe never.
    return @@responders[message_type].call(data) if @@responders.has_key?(message_type)

    @@reroutes_request[message_type].each do |tuple|
      data2 = tuple[1].call(data)
      return Aggregator.request(tuple[0], data2)
    end
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

  def self.subscribeAll(&callback : (String, String ->))
    @@subscribers_all << callback
  end

  def self.unSubscribeAll(&callback : (String, String ->))
    @@subscribers_all.delete(callback)
  end

  def self.reroute(from_type, to_type)
    self.reroute(from_type, to_type) do |data|
      data
    end
  end

  def self.reroute(from_type, to_type, &callback : (String -> String))
    @@reroutes[from_type] << {to_type, callback}
  end

  def self.un_reroute(from_type, to_type)
    @@reroutes[from_type].reject! { |tuple| tuple[0] == to_type }
  end

  def self.reroute_request(from_type, to_type)
    self.reroute_request(from_type, to_type) do |data|
      data
    end
  end

  def self.reroute_request(from_type, to_type, &callback : (String -> String))
    @@reroutes_request[from_type] << {to_type, callback}
  end

  def self.un_reroute_request(from_type, to_type)
    @@reroutes_request[from_type].reject! { |tuple| tuple[0] == to_type }
  end

  def self.resetAll(data)
    if data == "HARD"
      @@subscribers.clear
      @@subscribers_all.clear
      @@responders.clear
      @@reroutes.clear
      @@reroutes_request.clear
    end
  end
end

class String
  def subscribe(&callback : String ->)
    Aggregator.subscribe(self, &callback)
  end

  def unSubscribe(&callback : String ->)
    Aggregator.unSubscribe(self, &callback)
  end

  def respond(&callback : String -> String)
    Aggregator.respond(self, &callback)
  end

  def unRespond
    Aggregator.unRespond(self)
  end

  def publish(data)
    Aggregator.publish(self, data)
  end

  def request(data)
    Aggregator.request(self, data)
  end

  def reroute(data)
    Aggregator.reroute(self, data)
  end

  def reroute(data, &callback : (String -> String))
    Aggregator.reroute(self, data, &callback)
  end

  def un_reroute(data)
    Aggregator.un_reroute(self, data)
  end

  def reroute_request(data)
    Aggregator.reroute_request(self, data)
  end

  def reroute_request(data, &callback : (String -> String))
    Aggregator.reroute_request(self, data, &callback)
  end

  def un_reroute_request(data)
    Aggregator.un_reroute_request(self, data)
  end
end
