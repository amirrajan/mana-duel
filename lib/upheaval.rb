class Upheaval < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:snake, :dragon, :tiger]
  end
end
