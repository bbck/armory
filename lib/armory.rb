require 'nokogiri'
require 'typhoeus'

module Armory
  extend self

  autoload :VERSION, "armory/version"

  autoload :Guild,     "armory/guild"
  autoload :Character, "armory/character"

  USER_AGENT = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.4) Gecko/20100503 Firefox/3.6.4'

  class Error < Exception; end
  class NotFound < Error; end
  class ServiceUnavailable < Error; end
  class ServerError < Error; end

  Factions = {
    0 => "Alliance",
    1 => "Horde"
  }

  Genders = {
    0 => "Male",
    1 => "Female"
  }

  Races = {
    1  => "Human",
    2  => "Orc",
    3  => "Dwarf",
    4  => "Night Elf",
    5  => "Undead",
    6  => "Tauren",
    7  => "Gnome",
    8  => "Troll",
    10 => "Blood Elf",
    11 => "Draenei"
  }

  Classes = {
    1  => "Warrior",
    2  => "Paladin",
    3  => "Hunter",
    4  => "Rogue",
    5  => "Priest",
    6  => "Death Knight",
    7  => "Shaman",
    8  => "Mage",
    9  => "Warlock",
    11 => "Druid"
  }

  # TODO: Validate realms
  # TODO: Handle different regions
  # http://us.wowarmory.com/character-sheet.xml?r=Detheroc&n=Hunter
  def character_sheet(region, realm, character)
    response = make_request(region, 'character-sheet', :r => realm, :n => character)

    Character.from_armory(Nokogiri::XML(response.body))
  end

  def guild_info(region, realm, guild_name)
    response = make_request(region, 'guild-info', :r => realm, :gn => guild_name)

    Guild.from_armory(Nokogiri::XML(response.body))
  end

  private

  # TODO: Use region
  def make_request(region, page, params)
    response = Typhoeus::Request.get("http://us.wowarmory.com/#{page}.xml", {
                 :user_agent => USER_AGENT,
                 :params     => params
    })
    
    case response.code
    when 404
      raise NotFound, "Your request was not found."
    when 503
      raise ServiceUnavailable, "The armory has throlleted your request."
    when 500
      raise ServerError, "An unknown armory error occured."
    end
    
    return response
  end

end
