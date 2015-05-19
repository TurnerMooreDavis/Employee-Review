require 'byebug'
require "./db_setup"
class Employee < ActiveRecord::Base
  belongs_to :deparment
    @reviews = []
    @parsed = Array.new
    @positive_words = ["encourage","positive","well","good","improve","useful","value","pleasure","quick","willing","help","success","happy","responsive","effectiv","consistent","satisfied","impress","productiv","great","asset","enjoy","perfect","retain"]
    @negative_words = ["difficult", "confus", "negative", "inadequate","limit","fault","disagree","concern","slow","need","lack","not usefull","not done well","off topic"]

  def add_review(text)
    @reviews << text
  end

  def is_satisfactory(boolean)
    self.satisfactory = boolean
  end

  def give_raise(amount)
    self.salary += amount
  end

  def parse_review
    @reviews.each do |review|
      sentances = review.split(/\.|:/)
      sentances.each {|s| @parsed << s}
    end
    return true
  end

  def analyze(sentance)
    hold_positive = []
    hold_negative = []
    search_param = sentance
    hold_positive << @positive_words.select { |word| search_param.scan(/#{word}/).length > 0 ? true : false }
    hold_negative << @negative_words.select { |word| search_param.scan(/#{word}?s?ful?es?able?ly/).length > 0 ? true : false }
    hold_positive.flatten.length-hold_negative.flatten.length
  end

  def calculate_score
    total_score = 0
    calculator = lambda{ |sentance| total_score += yield (sentance) }
    @parsed.each &calculator
    # byebug
    if total_score <= 0
      self.satisfactory = false
    else
      self.satisfactory = true
    end
    return total_score
  end

  def add_trigger_word(word:,positive:)
    #
    if positive
      @positive_words << word
    else
      @negative_words << word
    end
  end


end
