require "hexp"
require "csv"

module Flashcards
  module CSV
    def load_csv(input)
      Deck.new(::CSV.open(input).map {|f,b| Card.new(front: f, back: b) })
    end
  end

  module HTMLOutput
    def write_deck(deck)
      H[:html, "\n",
        H[:body, {class: "flashcards-deck"}, "\n",
          *deck.map(&method(:write_card)), "\n"], "\n"]
    end

    def write_card(card)
      H[:div, {class: "card"}, "\n", write_hash(card.to_h), "\n"]
    end

    def write_hash(hash)
      H[:ul, "\n", *hash.map {|k,v|
          [
            H[:li, {class: "entry"},
              write_value(k).add_class(:key),
              ": ",
              write_value(v).add_class(:value)
             ],
            "\n"
          ]}.flatten(1)]
    end

    def write_value(v)
      H[:span, {"data-type" => v.class.to_s, "data-value" => v.to_s}, v.inspect]
    end

    def save_deck(deck, file)
      File.write(file, write_deck(deck).to_html)
    end
  end

  module HTMLInput
    def read_deck(h)
      Deck.new(h.select(".card").map(&method(:read_card)))
    end

    def read_card(h)
      Card.new(read_hash(h))
    end

    def read_hash(h)
      h.select(".entry").map {|e|
        [
          read_value(e.select(".key").first),
          read_value(e.select(".value").first)
        ]
      }.to_h
    end

    def read_value(h)
      val, type = h.attr("data-value"), h.attr("data-type")

      case type
      when "String"
        val
      when "Symbol"
        val.to_sym
      when "Fixnum"
        Integer(val)
      when "Float"
        Float(val)
      when "Time"
        Time.parse(val)
      when "TrueClass"
        true
      when "FalseClass"
        false
      when "NilClass"
        nil
      else
        raise "Unreadable type: #{type} => #{val}}"
      end
    end

    def load_deck(file)
      read_deck(Hexp.parse(File.read(file)))
    end

  end

  extend CSV, HTMLOutput, HTMLInput
end
