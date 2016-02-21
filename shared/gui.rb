#!/usr/bin/env ruby

require "pathname"

unless %w[fp oop].include?(ARGV[0])
  STDERR.puts "Usage: #{$0} fp"
  STDERR.puts "       #{$0} oop"
  exit -1
end

$LOAD_PATH.unshift(Pathname(__FILE__).join("../../#{ARGV[0]}/lib"))

require "flashcards"
require_relative "persistence"

require "shoes"
require "attribs"

NBSP="\u00A0"

def print_inspect!(deck)
  puts "-"*80
  deck.each do |card|
    puts " %4s | %4s | %.2f | %8.0f | %5s | %s " % [
           card.front,
           card.back,
           card.factor,
           card.interval,
           card.due?(Time.now).to_s,
           card.last_review_time && card.last_review_time.strftime("%Y-%m-%d %H:%M")
         ]
  end
end


class Session
  include Attribs.new(:location, :deck, current_card: nil)

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
    @deck = deck.answer_right(current_card, Time.now)
  end

  def answer_wrong!
    @deck = deck.answer_wrong(current_card, Time.now)
  end
end


Shoes.app do
  def card
    @session.current_card
  end

  def session
    @session
  end

  def next!
    if session
      print_inspect!(session.deck)

      session.next!

      if card
        @front.text = card.front
        @back.text = NBSP
        @show.show
        [@right, @wrong, @recheck].each(&:hide)
      else
        @front.text = "- done -"
        @back.text = NBSP
        [@right, @wrong, @show].each(&:hide)
        @recheck.show
      end
    else
      [@show, @right, @wrong, @recheck].each(&:hide)
    end

  end

  stack margin: 30 do
    @front = para NBSP, font: "50", margin: 20
    @back = para NBSP, font: "50", margin: 20

    flow do
      @show = button "Show", margin: 5 do
        @back.text = card.back
        @show.hide
        [@right, @wrong].each(&:show)
      end

      @right = button "Right", margin: 5 do
        session.answer_right!
        next!
      end

      @wrong = button "Wrong", margin: 5 do
        session.answer_wrong!
        next!
      end

      @recheck = button "Recheck", margin: 5 do
        next!
      end
    end

    flow do
      @load_deck = button "Load deck" do
        fname = ask_open_file

        if @session
          @session.close
          @session = nil
        end

        if fname
          @session = Session.open(fname)
        end

        next!
      end

      @load_csv = button "Import CSV" do
        fname = ask_open_file

        if @session
          @session.close
          @session = nil
        end

        if fname
          @session = Session.new(location: fname + ".html", deck: Flashcards.load_csv(fname))
        end
        next!

      end

      # @save_deck = button "Save deck" do
      #   fname = ask_save_file
      #   if fname
      #     Flashcards.save_deck(@deck, fname)
      #   end
      # end
    end
  end

  next!

  at_exit do
    @session.close
  end
end
