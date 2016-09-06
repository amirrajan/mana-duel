class Seppuku < Spell
  def initialize
    @type = :self
  end

  def damage
    15
  end

  def match? team
    (team[:primary].last == :ram && team[:assist].last == :ram) ||
      (team[:primary].last == :dragon && team[:assist].last == :dragon)
  end
end
