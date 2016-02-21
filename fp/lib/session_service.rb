module Flashcards
  class SessionService
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

    def handle_event(e)
      history.push(deck)
      puts e.pp
      @deck = e.call(@deck)
    end

    def answer_right!
      handle_event(Event.right_answer(current_card))
    end

    def answer_wrong!
      handle_event(Event.wrong_answer(current_card))
    end

    def undo!
      @deck = history.pop
      next!
    end
  end

end
