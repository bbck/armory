require 'spec_helper'

describe Armory do
  describe "#character_sheet" do
    # TODO: Handle title
    # TODO: Handle skills
    # TODO: Handle equipment
    it "should properly parse a character" do
      response = stub(
        :body => fixture("hunter"),
        :code => 200
      )
      Typhoeus::Request.expects(:get).with do |url, options|
        url.should == 'http://us.wowarmory.com/character-sheet.xml'
        options[:params].should == { :r => 'detheroc', :n => 'hunter' }
      end.returns(response)

      result = Armory.character_sheet('us', 'detheroc', 'hunter')

      # Basic information
      result.should be_instance_of(Armory::Character)
    end
    
    it "should raise appropriate errors if the rate limit has been reached" do
      response = stub(
        :body => '',
        :code => 503
      )
      Typhoeus::Request.expects(:get).returns(response)

      lambda do
        Armory.character_sheet('us', 'detheroc', 'hunter')
      end.should raise_exception(Armory::ServiceUnavailable)
    end

    it "should raise appropriate errors if the character cannot be found" do
      response = stub(
        :body => '',
        :code => 404
      )
      Typhoeus::Request.expects(:get).returns(response)

      lambda do
        Armory.character_sheet('us', 'detheroc', 'hunter')
      end.should raise_exception(Armory::NotFound)
      
      response = stub(
        :body => fixture("stale"),
        :code => 200
      )
      Typhoeus::Request.expects(:get).returns(response)

      lambda do
        Armory.character_sheet('us', 'blackrock', 'melana')
      end.should raise_exception(Armory::NotFound)
    end
    
    it "should raise appropiate errors if the armory in unavailable" do
      response = stub(
        :body => '',
        :code => 500
      )
      Typhoeus::Request.expects(:get).returns(response)
      
      lambda do
        Armory.character_sheet('us', 'detheroc', 'hunter')
      end.should raise_exception(Armory::ServerError)
    end
  end

  describe "#guild_info" do

    it "should properly parse a guild" do
      response = stub(
        :body => fixture("guild"),
        :code => 200
      )
      Typhoeus::Request.expects(:get).returns(response)

      result = Armory.guild_info('us', 'detheroc', 'ZeeGuild')

      result.name.should == "ZeeGuild"
      result.realm.should == "Detheroc"

      result.faction.should == "Horde"
      result.faction_id.should == 1

      result.characters.length.should == 7

      awesome = result.characters.find {|c| c.name == "MrAwesome" }

      awesome.class_name.should == "Mage"
      awesome.class_id.should == 8

      awesome.race.should == "Troll"
      awesome.race_id.should == 8

      awesome.level.should == 36
      awesome.rank.should == 1

      awesome.gender.should == "Male"
      awesome.gender_id.should == 0
    end

    it "should raise appropriate errors if the rate limit has been reached" do
      response = stub(
        :body => '',
        :code => 503
      )
      Typhoeus::Request.expects(:get).returns(response)

      lambda do
        Armory.guild_info('us', 'detheroc', 'ZeeGuild')
      end.should raise_exception(Armory::ServiceUnavailable)
    end

    it "should raise error if guild not found" do
      response = stub(
        :body => '',
        :code => 404
      )
      Typhoeus::Request.expects(:get).returns(response)

      lambda do
        Armory.guild_info('us', 'detheroc', 'ZeeGuild')
      end.should raise_exception(Armory::NotFound)
    end
    
    it "should raise appropiate errors if the armory in unavailable" do
      response = stub(
        :body => '',
        :code => 500
      )
      Typhoeus::Request.expects(:get).returns(response)
      
      lambda do
        Armory.guild_info('us', 'detheroc', 'ZeGuild')
      end.should raise_exception(Armory::ServerError)
    end
  end
end
