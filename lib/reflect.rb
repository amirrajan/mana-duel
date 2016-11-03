class Reflect < Spell
  def initialize
    @type = :defence
  end

  def sequence
    [:blue, :indigo]
  end

  def assist_sequence
    [:blue, :indigo]
  end

  def assist_sequence?
    true
  end

  def damage
    0
  end

  def match? team
    super && team[:assist].last == :indigo && team[:assist][-2] == :blue
  end
end
