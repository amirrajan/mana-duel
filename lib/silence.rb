class Silence < Spell
  def sequence
    [:snake, :rat, :dog]
  end

  def self.disables
    [:ox, :dog, :tiger, :snake]
  end
end
