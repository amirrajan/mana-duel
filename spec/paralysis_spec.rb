require './spec/spec_helper.rb'

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

describe 'paralysis: tiger, tiger, tiger' do
  specify 'the opposite team\'s unit must repeat the last turn\'s spell (if :left, :a casts paralysis then :left, :b is paralized)' do
    game = Game.new
    game.turn({ left: :tiger },
              {})
    game.turn({ left: :tiger },
              {})
    summary = game.turn({ left: :tiger },
                        { left: :dragon })

    summary[:a][:left][:spell][:name].should eq 'Paralysis'
    game.enchantment_status[:b][:left].should eq Paralysis

    summary[:b][:left][:restrictions][:commands].should eq [:dragon]
    summary[:b][:left][:restrictions][:because_of].should eq 'Paralysis'
    summary[:b][:right][:restrictions].should be nil

    game = Game.new
    game.turn({ right: :tiger }, {})
    game.turn({ right: :tiger }, {})
    summary = game.turn({ right: :tiger },
                        { right: :dragon })

    summary[:a][:right][:spell][:name].should eq 'Paralysis'
    game.enchantment_status[:b][:right].should eq Paralysis

    summary[:b][:right][:restrictions][:commands].should eq [:dragon]
    summary[:b][:right][:restrictions][:because_of].should eq 'Paralysis'
    summary[:b][:left][:restrictions].should be nil
  end

  specify 'executing a restricted command will get changed' do
    game = Game.new
    game.turn({ left: :tiger },
              {})
    game.turn({ left: :tiger },
              {})
    game.turn({ left: :tiger },
              { left: :dragon })
    summary = game.turn({ left: :tiger },
                        { left: :rat })

    summary[:b][:left][:command].should eq :dragon

    game = Game.new
    game.turn({ right: :tiger },
              {})
    game.turn({ right: :tiger },
              {})
    game.turn({ right: :tiger },
              { right: :dragon })
    summary = game.turn({ right: :tiger }, { right: :rat })

    summary[:b][:right][:command].should eq :dragon
  end

  specify 'a subsequent paralysis affects the same unit' do
    game = Game.new
    game.turn({ left: :tiger },
              {})
    game.turn({ left: :tiger,  right: :tiger },
              {})
    # paralysis from left
    game.turn({ left: :tiger,  right: :tiger },
              { left: :dragon })

    # followed by paralysis from right
    summary = game.turn(
      {                right: :tiger },
      { left: :dragon, right: :rat })

    # leaves left paralyzed as opposed to switching
    summary[:a][:right][:spell][:name].should eq 'Paralysis'
    game.enchantment_status[:b][:left].should eq Paralysis

    summary[:b][:left][:restrictions][:commands].should eq [:dragon]
    summary[:b][:left][:restrictions][:because_of].should eq 'Paralysis'
    summary[:b][:right][:restrictions].should be nil

    game = Game.new
    game.turn({                right: :tiger },
              {})
    game.turn({ left: :tiger,  right: :tiger },
              {})
    # paralysis from left
    game.turn({ left: :tiger,  right: :tiger },
              {                right: :dragon })

    # followed by paralysis from right
    summary = game.turn({ left: :tiger },
                        { left: :dragon, right: :rat })

    # leaves left paralyzed as opposed to switching
    summary[:a][:left][:spell][:name].should eq 'Paralysis'
    game.enchantment_status[:b][:right].should eq Paralysis

    summary[:b][:right][:restrictions][:commands].should eq [:dragon]
    summary[:b][:right][:restrictions][:because_of].should eq 'Paralysis'
    summary[:b][:left][:restrictions].should be nil
  end

  it 'cannot be nullified by a shield' do
    game = Game.new
    game.turn({ left: :tiger },
              {})
    game.turn({ left: :tiger },
              {})
    summary = game.turn({ left: :tiger },
                        { left: :dragon })

    summary[:a][:left][:spell][:nullified].should eq false
    summary[:b][:left][:restrictions][:commands].should eq [:dragon]
  end

  it 'can be nullifed by counter spell' do
    game = Game.new

    game.turn({ left: :tiger },
              { right: :rat })

    game.turn({ left: :tiger },
              { right: :dragon })

    summary = game.turn({ left: :tiger },
                        { right: :dragon })

    summary[:b][:right][:spell][:name].should eq 'CounterSpell'
    summary[:b][:right][:spell][:nullified].should eq false

    summary[:a][:left][:spell][:name].should eq 'Paralysis'
    summary[:a][:left][:spell][:nullified].should eq true

    summary[:a][:left][:restrictions].should be nil
    summary[:a][:right][:restrictions].should be nil

    summary = game.turn({ left: :ram, right: :ram },
                        { left: :ram, right: :ram })

    summary[:a][:left][:command].should eq :ram
    summary[:a][:right][:command].should eq :ram
    summary[:b][:left][:command].should eq :ram
    summary[:b][:right][:command].should eq :ram
  end

  it 'can be reflected' do
    game = Game.new
    game.turn({ left: :tiger }, {})
    game.turn({ left: :tiger },
              { left: :ox, right: :ox })
    summary = game.turn({ left: :tiger },
                        { left: :rat, right: :rat })

    summary[:b][:right][:spell][:name].should eq 'Reflect'
    summary[:a][:right][:spell][:nullified].should eq false

    summary[:a][:left][:spell][:name].should eq 'Paralysis'
    summary[:a][:left][:spell][:nullified].should eq true

    summary[:b][:left][:restrictions].should be nil
    summary[:a][:left][:restrictions][:commands].should eq [:tiger]

    summary = game.turn({ left: :dragon },
                        { left: :ram, right: :dragon })

    summary[:a][:left][:command].should eq :tiger
    summary[:b][:left][:command].should eq :ram
    summary[:b][:right][:command].should eq :dragon
  end

  it 'restricts to a different command if ox, snake or rat is issued' do
    [
      { command: :ox, replaced_with: :tiger },
      { command: :snake, replaced_with: :dog },
      { command: :rat, replaced_with: :dragon }
    ].each do |row|
      game = Game.new
      game.turn({ left: :tiger }, {})
      game.turn({ left: :tiger }, {})
      summary = game.turn({ left: :tiger },
                          { left: row[:command] })

      summary[:a][:left][:spell][:name].should eq 'Paralysis'
      game.enchantment_status[:b][:left].should eq Paralysis

      summary[:b][:left][:restrictions][:commands].should eq [row[:replaced_with]]
      summary[:b][:left][:restrictions][:because_of].should eq 'Paralysis'

      summary = game.turn({},
                          { left: :ram })

      summary[:b][:left][:command].should eq row[:replaced_with]
    end
  end
end
