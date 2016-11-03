require './spec/spec_helper.rb'

describe 'Shield' do
  let(:game) { Game.new }

  it 'stops all damage for one turn (invoking the sign :red creates a shield)' do
    game.turn({ left: :red, right: :orange },
              { left: :red, right: :orange })

    game.damage_for(:a).should be 0
    game.damage_for(:b).should be 0
  end

  it 'timed against a missile, the damaged is stopped' do
    game.turn({ left: :green },
              {})

    game.turn({ left: :yellow },
              { left: :red })

    game.damage_for(:b).should be 0
  end
end

describe 'Shield: summary' do
  let(:game) { Game.new }

  it 'reports nullfication in the summary' do
    summary = game.turn({ left: :red, right: :orange },
                        { left: :orange, right: :red })

    # turn
    summary[:turn].should eq 1

    # activated spells
    summary[:a][:left][:command].should eq :red
    summary[:a][:left][:spell][:name].should eq 'Shield'
    summary[:a][:left][:spell][:nullified].should eq false

    summary[:b][:right][:command].should eq :red
    summary[:b][:right][:spell][:name].should eq 'Shield'
    summary[:b][:right][:spell][:nullified].should eq false

    # nullified spells
    summary[:a][:right][:command].should eq :orange
    summary[:a][:right][:spell][:name].should eq 'Shock'
    summary[:a][:right][:spell][:nullified].should eq true

    summary[:b][:left][:command].should eq :orange
    summary[:b][:left][:spell][:name].should eq 'Shock'
    summary[:b][:left][:spell][:nullified].should eq true
  end
end
