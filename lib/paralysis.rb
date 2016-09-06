class Paralysis < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:tiger, :tiger, :tiger]
  end
end
