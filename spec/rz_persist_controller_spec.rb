require "rspec"

# This adds Razor Common lib path to the load path for this child proc
$LOAD_PATH << "#{ENV['RAZOR_HOME']}/lib/common"

require "rz_configuration"
require "rz_persist_controller"
require "rz_model"
require "uuid"

describe RZPersistController do
  before(:each) do
        @config = RZConfiguration.new
        @config.persist_mode = :mongo
        @persist = RZPersistController.new(@config)
  end

  after(:each) do
        @persist.teardown
  end

  describe ".Initialize" do
    it "should create a PersistMongo object for .persist_obj if config persist_mode is :mongo" do
      @persist.persist_obj.class.should == RZPersistMongo
    end

    it "should have stored config object and it should match" do
      @persist.config.should == @config
    end

    it "should have established a connection on initialization" do
      @persist.is_connected?.should == true
    end

  end

  describe ".Connection" do
    it "should connect to DatabaseEngine successfully using details in config" do
      @persist.is_connected?.should == true
    end

    it "should disconnect from DatabaseEngine successfully when teardown called" do
      if @persist.check_connection  # make sure we have it open
        @persist.teardown  # do teardown
        @persist.is_connected?.should == false  # should be false now
      else
        false # without an open connection we can't test
      end
    end

    it "should reconnect should the connection drop/timeout" do
      if @persist.check_connection  # make sure we have it open
        @persist.teardown  # do teardown to break connection
        if !@persist.is_connected?  # make sure it is not connected
          @persist.check_connection.should == true  # should reconnect
        else
          false # we couldn't kill the connection for some reason
        end
      else
        false # without an open connection we can't test
      end
    end
  end

  describe ".DatabaseBinding" do
    before(:each) do
      @persist.check_connection
    end

    it "should select/connect/bind to Razor database within DatabaseEngine successfully" do
      @persist.persist_obj.is_db_selected?.should == true
    end
  end



  describe ".Model" do
    before(:all) do
      @new_uuid = UUID.new
      @model1 = RZModel.new({:@name => "rspec_modelname01", :@guid => @new_uuid.to_s, :@model_type => "base", :@values_hash => {"a" => "1"}})
      @model2 = RZModel.new({:@name => "rspec_modelname02", :@guid => @new_uuid.to_s, :@model_type => "base", :@values_hash => {"a" => "1"}})
      @model3 = RZModel.new({:@name => "rspec_modelname03", :@guid => @new_uuid.to_s, :@model_type => "base", :@values_hash => {"a" => "1"}})
    end

    it "should be able to add/update a Model to the Model collection" do
      flag = false

      @persist.model_update(@model1)
      sleep(1)

      @persist.model_update(@model2)
      sleep(1)

      @persist.model_update(@model3)

      model_array = @persist.model_get_all
      model_array.each do
        |m|
        if m.guid == @new_uuid.to_s
          flag = true
        end
      end
      flag.should == true
    end
    it "should see the last update to a Model in the collection" do
      flag = false
      model_array = @persist.model_get_all
      model_array.each do
        |m|
        if m.guid == @new_uuid.to_s
          if m.name == "rspec_modelname03"
            flag = true
          end
        end
      end
      flag.should == true
    end
    it "should return a array of Models from the Model collection without duplicates" do
      model_array = @persist.model_get_all
      model_array.inspect

      x = 0
      model_array.each do
        |m|
        if m.guid == @new_uuid.to_s
          x += 1
        end
      end
      x.should == 1

    end
    it "should remove a Model from the Model collection" do

      @persist.model_remove(@model3)

      x = 0
      model_array = @persist.model_get_all
      model_array.each do
        |m|
        if m.guid == @new_uuid.to_s
          x += 1
        end
      end
      x.should == 0
    end
  end

  describe ".Policy" do
    it "should add a Policy to the Policy collection"
    it "should read a Policy from the Policy collection"
    it "should return a array of Policy from the Policy collection"
    it "should remove a Policy from the Policy collection"
    it "should update an existing Policy in the Policy collection"
  end

  describe ".State" do
    describe ".LastState" do
      it "should read the LastState of a specific node"
      it "should set the LastState of a specific node"
      it "should get an array of nodes of a specific LastState"
      it "should get an array of all nodes LastState"
    end

    describe ".CurrentState" do
      it "should read the CurrentState of a specific node"
      it "should set the CurrentState of a specific node"
      it "should get an array of nodes of a specific CurrentState"
      it "should get an array of all nodes CurrentState"
    end

    describe ".NextState" do
      it "should read the NextState of a specific node"
      it "should set the NextState of a specific node"
      it "should get an array of nodes of a specific NextState"
      it "should get an array of all nodes NextState"
    end
  end
end