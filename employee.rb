require 'byebug'
require "./db_setup"
class Employee < ActiveRecord::Base
  belongs_to :department
  def add_review(text)
    self.review = text
  end

  def is_satisfactory(boolean)
    self.satisfactory = boolean
  end

  def give_raise(amount)
    self.salary += amount
  end

  # def parse_review
  #   sentances = review.split(/\.|:/)
  #   sentances.each {|s| parsed_text << s}
  #   return true
  # end

  def analyze(review)
    
    hold_positive = []
    hold_negative = []
    hold_positive << ["encourage","positive","well","good","improve","useful","value","pleasure","quick","willing","help","success","happy","responsive","effectiv","consistent","satisfied","impress","productiv","great","asset","enjoy","perfect","retain"].select {|word| word.scan(review)}
    hold_negative << ["difficult", "confus", "negative", "inadequate","limit","fault","disagree","concern","slow","need","lack","not usefull","not done well","off topic"].select {|word| word.scan(review)}
    hold_positive.flatten.length-hold_negative.flatten.length
  end

  def calculate_score
    total_score = 0
    total_score += yield (self.review)
    # byebug
    if total_score <= 0
      self.satisfactory = false
    else
      self.satisfactory = true
    end
    return total_score
  end

  # def add_trigger_word(word:,positive:)
  #   #
  #   if positive
  #     @positive_words << word
  #   else
  #     @negative_words << word
  #   end
  # end


end
