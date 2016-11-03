require './spec/spec_helper.rb'

=begin
F = violet
P = red
S = green
W = indigo
D = yellow
C = [blue, blue]
(stab) = orange
nothing () = Wait
=end

describe 'paralysis: violet, violet, violet' do
  specify 'the opposite team\'s unit must repeat the last turn\'s spell (if :left, :a casts paralysis then :left, :b is paralized)' do
    game = Game.new
    game.turn({ left: :violet },
              {})
    game.turn({ left: :violet },
              {})
    summary = game.turn({ left: :violet },
                        { left: :red })

    summary[:a][:left][:spell][:name].should eq 'Paralysis'
    game.enchantment_status[:b][:left].should eq Paralysis

    summary[:b][:left][:restrictions][:commands].should eq [:red]
    summary[:b][:left][:restrictions][:because_of].should eq 'Paralysis'
    summary[:b][:right][:restrictions].should be nil

    game = Game.new
    game.turn({ right: :violet }, {})
    game.turn({ right: :violet }, {})
    summary = game.turn({ right: :violet },
                        { right: :red })

    summary[:a][:right][:spell][:name].should eq 'Paralysis'
    game.enchantment_status[:b][:right].should eq Paralysis

    summary[:b][:right][:restrictions][:commands].should eq [:red]
    summary[:b][:right][:restrictions][:because_of].should eq 'Paralysis'
    summary[:b][:left][:restrictions].should be nil
  end

  specify 'executing a restricted command will get changed' do
    game = Game.new
    game.turn({ left: :violet },
              {})
    game.turn({ left: :violet },
              {})
    game.turn({ left: :violet },
              { left: :red })
    summary = game.turn({ left: :violet },
                        { left: :indigo })

    summary[:b][:left][:command].should eq :red

    game = Game.new
    game.turn({ right: :violet },
              {})
    game.turn({ right: :violet },
              {})
    game.turn({ right: :violet },
              { right: :red })
    summary = game.turn({ right: :violet }, { right: :indigo })

    summary[:b][:right][:command].should eq :red
  end

  specify 'a subsequent paralysis affects the same unit' do
    game = Game.new
    game.turn({ left: :violet },
              {})
    game.turn({ left: :violet,  right: :violet },
              {})
    # paralysis from left
    game.turn({ left: :violet,  right: :violet },
              { left: :red })

    # followed by paralysis from right
    summary = game.turn(
      {                right: :violet },
      { left: :red, right: :indigo })

    # leaves left paralyzed as opposed to switching
    summary[:a][:right][:spell][:name].should eq 'Paralysis'
    game.enchantment_status[:b][:left].should eq Paralysis

    summary[:b][:left][:restrictions][:commands].should eq [:red]
    summary[:b][:left][:restrictions][:because_of].should eq 'Paralysis'
    summary[:b][:right][:restrictions].should be nil

    game = Game.new
    game.turn({                right: :violet },
              {})
    game.turn({ left: :violet,  right: :violet },
              {})
    # paralysis from left
    game.turn({ left: :violet,  right: :violet },
              {                right: :red })

    # followed by paralysis from right
    summary = game.turn({ left: :violet },
                        { left: :red, right: :indigo })

    # leaves left paralyzed as opposed to switching
    summary[:a][:left][:spell][:name].should eq 'Paralysis'
    game.enchantment_status[:b][:right].should eq Paralysis

    summary[:b][:right][:restrictions][:commands].should eq [:red]
    summary[:b][:right][:restrictions][:because_of].should eq 'Paralysis'
    summary[:b][:left][:restrictions].should be nil
  end

  it 'cannot be nullified by a shield' do
    game = Game.new
    game.turn({ left: :violet },
              {})
    game.turn({ left: :violet },
              {})
    summary = game.turn({ left: :violet },
                        { left: :red })

    summary[:a][:left][:spell][:nullified].should eq false
    summary[:b][:left][:restrictions][:commands].should eq [:red]
  end

  it 'can be nullifed by counter spell' do
    game = Game.new

    game.turn({ left: :violet },
              { right: :indigo })

    game.turn({ left: :violet },
              { right: :red })

    summary = game.turn({ left: :violet },
                        { right: :red })

    summary[:b][:right][:spell][:name].should eq 'CounterSpell'
    summary[:b][:right][:spell][:nullified].should eq false

    summary[:a][:left][:spell][:name].should eq 'Paralysis'
    summary[:a][:left][:spell][:nullified].should eq true

    summary[:a][:left][:restrictions].should be nil
    summary[:a][:right][:restrictions].should be nil

    summary = game.turn({ left: :orange, right: :orange },
                        { left: :orange, right: :orange })

    summary[:a][:left][:command].should eq :orange
    summary[:a][:right][:command].should eq :orange
    summary[:b][:left][:command].should eq :orange
    summary[:b][:right][:command].should eq :orange
  end

  it 'can be reflected' do
    game = Game.new
    game.turn({ left: :violet }, {})
    game.turn({ left: :violet },
              { left: :blue, right: :blue })
    summary = game.turn({ left: :violet },
                        { left: :indigo, right: :indigo })

    summary[:b][:right][:spell][:name].should eq 'Reflect'
    summary[:a][:right][:spell][:nullified].should eq false

    summary[:a][:left][:spell][:name].should eq 'Paralysis'
    summary[:a][:left][:spell][:nullified].should eq true

    summary[:b][:left][:restrictions].should be nil
    summary[:a][:left][:restrictions][:commands].should eq [:violet]

    summary = game.turn({ left: :red },
                        { left: :orange, right: :red })

    summary[:a][:left][:command].should eq :violet
    summary[:b][:left][:command].should eq :orange
    summary[:b][:right][:command].should eq :red
  end

  it 'restricts to a different command if blue, green or indigo is issued' do
    [
      { command: :blue, replaced_with: :violet },
      { command: :green, replaced_with: :yellow },
      { command: :indigo, replaced_with: :red }
    ].each do |row|
      game = Game.new
      game.turn({ left: :violet }, {})
      game.turn({ left: :violet }, {})
      summary = game.turn({ left: :violet },
                          { left: row[:command] })

      summary[:a][:left][:spell][:name].should eq 'Paralysis'
      game.enchantment_status[:b][:left].should eq Paralysis

      summary[:b][:left][:restrictions][:commands].should eq [row[:replaced_with]]
      summary[:b][:left][:restrictions][:because_of].should eq 'Paralysis'

      summary = game.turn({},
                          { left: :orange })

      summary[:b][:left][:command].should eq row[:replaced_with]
    end
  end
end
