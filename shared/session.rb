require "attribs"

module Flashcards
  class Session
    include Attribs.new(:location, :deck, current_card: nil, history: [])

    def initialize(**args)
      super(args)
    end

    def self.open(file)
      new(location: file, deck: Flashcards.load_deck(file))
    end

    def close
      Flashcards.save_deck(deck, location)
    end

    def next!
      @current_card = deck.next(Time.now)
    end

    def answer_right!
      history.push(deck)
      @deck = deck.answer_right(current_card, Time.now)
    end

    def answer_wrong!
      history.push(deck)
      @deck = deck.answer_wrong(current_card, Time.now)
    end

    def undo!
      @deck = history.pop
      next!
    end
  end
end
