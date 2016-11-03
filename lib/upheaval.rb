class Upheaval < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:green, :red, :violet]
  end
end
