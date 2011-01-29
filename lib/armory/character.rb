require 'date'

module Armory
  class Character

    attr_accessor :name, :level, :guild, :realm, :battle_group, :points, :last_modified
    attr_accessor :class_id, :gender_id, :race_id, :faction_id, :title_id
    attr_reader :items, :arena_teams

    def initialize
      @items = []
      @arena_teams = []
    end

    def class_name
      Armory::Classes[class_id]
    end

    def gender
      Armory::Genders[gender_id]
    end

    def race
      Armory::Races[race_id]
    end

    def faction
      Armory::Factions[faction_id]
    end

    def self.from_armory(doc)
      Character.new.tap do |char|
        if doc.css("characterInfo").attr("errCode")
          case doc.css("characterInfo").attr("errCode").to_s
          when "noCharacter"
            raise NotFound, "Your request was not found."
          end
        end
        
        info = doc.css("characterInfo character").first

        char.name  = info.attr("name")
        char.level = info.attr("level").to_i
        char.guild = info.attr("guildName")
        char.realm = info.attr("realm")
        char.battle_group  = info.attr("battleGroup")
        char.points = info.attr("points").to_i
        char.last_modified = Date.parse(info.attr('lastModified')) unless info.attr('noCharacter')

        # Attribute ids
        char.race_id    = info.attr("raceId").to_i
        char.class_id   = info.attr("classId").to_i
        char.gender_id  = info.attr("genderId").to_i
        char.faction_id = info.attr("factionId").to_i
        char.title_id   = info.attr("titleId").to_i unless info.attr('noCharacter')
        
        doc.css("characterTab items item").each do |item|
          char.items << Item.from_armory(item)
        end

        doc.css("arenaTeams arenaTeam").each do |team|
          char.arena_teams << ArenaTeam.from_armory(team)
        end
      end
    end

    class Item
      attr_accessor :id, :name, :level, :slot, :rarity
      attr_accessor :durability, :max_durability, :enchant_id
      attr_reader :gems

      def initialize
        @gems = []
      end

      def self.from_armory(doc)
        Item.new.tap do |item|
          item.id     = doc.attr('id').to_i
          item.name   = doc.attr('name')
          item.level  = doc.attr('level').to_i
          item.slot   = doc.attr('slot').to_i
          item.rarity = doc.attr('rarity').to_i

          item.durability     = doc.attr('durability').to_i
          item.max_durability = doc.attr('maxDurability').to_i
          item.enchant_id     = doc.attr('permanentEnchantItemId').to_i

          3.times do |i|
            gem = doc.attr("gem#{i}Id").to_i
            item.gems << gem if gem != 0
          end
        end
      end
    end
 
    class ArenaTeam
      attr_accessor :name, :size, :rating, :ranking
      attr_accessor :games_played, :games_won
      attr_reader :members
      
      def initialize
        @members = []
      end
      
      def self.from_armory(doc)
        ArenaTeam.new.tap do |team|
          team.name         = doc.attr('name')
          team.size         = doc.attr('size').to_i
          team.rating       = doc.attr('rating').to_i
          team.ranking      = doc.attr('ranking').to_i
          team.games_played = doc.attr('seasonGamesPlayed').to_i
          team.games_won    = doc.attr('seasonGamesWon').to_i
          
          doc.css("members character").each do |member|
            team.members << ArenaTeamMember.from_armory(member)
          end
        end
      end
    end
    
    class ArenaTeamMember
      attr_accessor :name, :guild, :class_id, :gender_id, :race_id, :rating
      attr_accessor :games_played, :games_won
      
      def class_name
        Armory::Classes[class_id]
      end

      def gender
        Armory::Genders[gender_id]
      end

      def race
        Armory::Races[race_id]
      end
      
      def self.from_armory(doc)
        ArenaTeamMember.new.tap do |member|
          member.name         = doc.attr('name')
          member.guild        = doc.attr('guild')
          member.class_id     = doc.attr("classId").to_i
          member.gender_id    = doc.attr("genderId").to_i
          member.race_id      = doc.attr("raceId").to_i
          member.rating       = doc.attr('contribution').to_i
          member.games_played = doc.attr('seasonGamesPlayed').to_i
          member.games_won    = doc.attr('seasonGamesWon').to_i
        end
      end
    end
  end
end
