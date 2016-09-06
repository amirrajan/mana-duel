class Amnesia < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:dog, :dragon, :dragon]
  end
end
