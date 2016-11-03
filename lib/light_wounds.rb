class LightWounds < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:indigo, :violet, :red]
  end

  def damage
    2
  end
end
