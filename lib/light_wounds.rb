class LightWounds < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:rat, :tiger, :dragon]
  end

  def damage
    2
  end
end
