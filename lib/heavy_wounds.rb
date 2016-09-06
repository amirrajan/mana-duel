class HeavyWounds < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:rat, :dragon, :tiger, :dog]
  end

  def damage
    3
  end
end
