class Reflect < Spell
  def initialize
    @type = :defence
  end

  def sequence
    [:ox, :rat]
  end

  def assist_sequence
    [:ox, :rat]
  end

  def assist_sequence?
    true
  end

  def damage
    0
  end

  def match? team
    super && team[:assist].last == :rat && team[:assist][-2] == :ox
  end
end
