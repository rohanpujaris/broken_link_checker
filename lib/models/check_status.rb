require 'active_record'

class CheckStatus < ActiveRecord::Base
  has_many :items
end
