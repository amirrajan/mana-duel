class HeavyWounds < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:indigo, :red, :violet, :yellow]
  end

  def damage
    3
  end
end
