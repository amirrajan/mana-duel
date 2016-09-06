class Turn < ActiveRecord::Base
  attr_accessible :command, :level, :turn, :user_id, :unit
end
