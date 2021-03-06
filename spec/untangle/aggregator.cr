require "./../spec_helper"

def capture(x, &block)
  block
end

def catch_proc(&block : String -> String)
  block
end

def catch_proc(&block : (String, String) -> String)
  block
end

def return_data(x)
  x
end

describe Aggregator do
  Spec.before_each do
    Aggregator.resetAll("HARD")
  end

  it "self.subscribe (message_type, callback : Proc) exists" do
    a = false
    Aggregator.subscribe("test") do |data|
      a = data
    end

    Aggregator.publish("test", "true")
    a.should eq "true"
  end

  it "self.unSubscribe (message_type, callback : Proc) exists" do
    a = false
    callback = catch_proc { |data|
      a = data
    }

    Aggregator.subscribe("test") do
      callback
    end
    Aggregator.unSubscribe("test") do
      callback
    end
    # sleep 10.0
    Aggregator.publish("test", "true")
    a.should eq false
  end
  it "self.respond (message_type, callback : Proc) exists" do
    rdata = ->return_data(String)
    Aggregator.respond("test", &rdata)

    Aggregator.request("test", "data").should eq "data"
    Aggregator.request("test").should eq ""
  end
  it "self.unRespond (message_type, callback : Proc) exists" do
    Aggregator.respond("test") do |data|
      next "a"
    end
    Aggregator.unRespond("test")

    Aggregator.request("test", "data").should eq nil
    Aggregator.request("test").should eq nil
  end
  # This is being tested in the first test
  # it "self.publish (message_type, data) exists" do
  # 	a = "false"
  # 	Aggregator.subscribe("test") do |data|
  # 		a = data
  # 	end
  # 	Aggregator.publish("test", "true")
  # 	a.should eq "true"
  # end
  it "self.request(*arguments) exists" do
    Aggregator.respond("test") do |data|
      next "data"
    end

    Aggregator.request("test", "data").should eq "data"
  end
  it "self.helpers exists" do
    # Not sure if it is possible to dynamically add methods to objects in Crystal. This type of meta-prog. does not appear to be implemented yet.
    Aggregator.helpers
  end
  it "self.subscribeAll (callback : Proc) exists" do
    mtype = nil
    mdata = nil
    Aggregator.subscribeAll() do |message_type, data|
      mtype = message_type
      mdata = data
    end

    Aggregator.publish("message", "data")
    mtype.should eq "message"
    mdata.should eq "data"
  end
  it "self.unSubscribeAll (callback : Proc) exists" do
    mtype = nil
    mdata = nil
    callback = catch_proc { |message_type, data|
      mtype = message_type
      mdata = data
    }
    Aggregator.subscribeAll do
      callback
    end
    Aggregator.unSubscribeAll do
      callback
    end

    Aggregator.publish("message", "data")
    mtype.should eq nil
    mdata.should eq nil
  end
  it "self.reroute (from_type, to_type, &callback : (String -> String)) exists" do
    Aggregator.reroute("test", "testnew") do |data|
      next "data"
    end
    Aggregator.reroute("test", "testnew2")
  end
  it "self.un_reroute (from_type, to_type) exists" do
    Aggregator.un_reroute("test", "testnew")
  end

  it "self.reroute_request (from_type, to_type, &callback : (String -> String)) exists" do
    Aggregator.respond("test") do |data|
      next data
    end
    Aggregator.reroute_request("testnew", "test") do |data|
      next "data1"
    end
    Aggregator.request("test", "data").should eq "data"
    Aggregator.request("testnew", "data").should eq "data1"

    Aggregator.reroute_request("testnew2", "test")
    Aggregator.request("testnew2", "data").should eq "data"
  end
  it "self.un_reroute_request (from_type, to_type) exists" do
    Aggregator.respond("test") do |data|
      next data
    end

    Aggregator.reroute_request("testnew", "test") do |data|
      next "data1"
    end
    Aggregator.un_reroute_request("testnew", "test")
    Aggregator.request("testnew", "data").should eq nil

    Aggregator.reroute_request("testnew", "test")
    Aggregator.un_reroute_request("testnew", "test")
    Aggregator.request("testnew", "data").should eq nil
  end

  it "self.resetAll (data) exists" do
    Aggregator.respond("test") do |data|
      next data
    end
    validator_data = false
    Aggregator.subscribe("test") do |data|
      validator_data = true
      next data
    end
    Aggregator.resetAll("test") # Nothing happens
    Aggregator.request("test", "data").should eq "data"
    Aggregator.publish("test", "data")
    validator_data.should eq true

    validator_data = false
    Aggregator.resetAll("HARD") # something happens
    Aggregator.request("test", "data").should eq nil
    Aggregator.publish("test", "data")
    validator_data.should eq false
  end

  it "adds methods to the string class" do
    callback = catch_proc { |data|
      data
    }
    "".subscribe do |data|
      data
    end
    "".subscribe do
      callback
    end
    "".unSubscribe do
      callback
    end
    "".respond do |data|
      data
    end
    "".respond do |data|
      next data
    end
    "".unRespond
    "".publish("data")
    "".request("data")
    "".reroute("new route") do |data|
      next data
    end
    # "".reroute("new route") do callback end
    "".un_reroute("new route")
  end
  it "string-helpers: handles subscribe and publish correctly" do
    testdata = false
    "test".subscribe do |data|
      testdata = data
    end
    "test".publish("data")
    testdata.should eq "data"
  end
  it "string-helpers: handles unSubscribe correctly" do
    testdata = false
    callback = catch_proc { |data|
      testdata = data
    }
    "test".subscribe do
      callback
    end
    "test".unSubscribe do
      callback
    end
    "test".publish("data")
    testdata.should eq false
  end
  it "string-helpers: handles respond and request" do
    "test".respond do |data|
      next data + "i"
    end
    "test".request("data").should eq "datai"
  end
  it "string-helpers: handles reroute" do
  end
  it "string-helpers: handles reroute_request" do
    "test".respond do |data|
      next data + "i"
    end
    "test2".reroute_request("test")
    "test2".request("data").should eq "datai"
  end
  it "string-helpers: handles reroute_request with callback" do
    "test".respond do |data|
      data + "i"
    end
    "test2".reroute_request("test") do |data|
      data + "i"
    end
    "test2".request("data").should eq "dataii"
  end
end
