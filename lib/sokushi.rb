=begin
F = Tiger
P = Dragon
S = Snake
W = Rat
D = Dog
C = [Ox, Ox]
(stab) = Ram
nothing () = Wait
=end

class Sokushi < Spell
  def initialize
    @type = :attack
  end

  def sequence
    [:dragon, :rat, :dragon, :tiger,
     :snake, :snake, :snake, :dog]
  end

  def damage
    100
  end
end
