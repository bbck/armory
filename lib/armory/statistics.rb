module Armory
  class Statistics
    attr_reader :statistics
    
    def initialize
      @statistics = []
    end
    
    def self.from_armory(doc)
      Statistics.new.tap do |char|
        doc.css("category statistic").each do |statistics|
          char.statistics << Statistic.from_armory(statistics)
        end
      end
    end
    
    class Statistic
      attr_accessor :id, :name, :highest, :quantity
      
      def self.from_armory(doc)
        Statistic.new.tap do |statistic|
          statistic.id          = doc.attr('id').to_i
          statistic.name        = doc.attr('name')
          statistic.highest     = doc.attr("highest")
          statistic.quantity    = doc.attr("quantity").to_i unless doc.attr("quantity") == '--'
        end
      end
    end
  end
end