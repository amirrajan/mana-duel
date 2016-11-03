class Paralysis < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:violet, :violet, :violet]
  end
end
