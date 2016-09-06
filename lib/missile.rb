class Missile < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:snake, :dog]
  end

  def damage
    1
  end
end
