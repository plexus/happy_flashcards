require 'csv'
require 'delegate'

module Flashcards
  def self.load_csv(input)
    Deck.new.tap do |deck|
      CSV.open(input).each do |f,b|
        deck << Card.new(f,b)
      end
    end
  end

  class Deck < SimpleDelegator
    def initialize
      super([])
    end
  end

  class Card < Struct.new(:front, :back)
  end
end
