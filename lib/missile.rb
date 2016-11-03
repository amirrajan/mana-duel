class Missile < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:green, :yellow]
  end

  def damage
    1
  end
end
