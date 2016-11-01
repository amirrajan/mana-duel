require_relative 'lib/spell.rb'
require_relative 'lib/available_commands.rb'
require_relative 'lib/activated_spells.rb'
require_relative 'lib/wait.rb'
require_relative 'lib/paralysis.rb'
require_relative 'lib/fast_lightning_bolt.rb'
require_relative 'lib/lightning_bolt.rb'
require_relative 'lib/silence.rb'
require_relative 'lib/ultimate_defense.rb'
require_relative 'lib/shock.rb'
require_relative 'lib/upheaval.rb'
require_relative 'lib/amnesia.rb'
require_relative 'lib/heal.rb'
require_relative 'lib/greater_heal.rb'
require_relative 'lib/counter_spell.rb'
require_relative 'lib/light_wounds.rb'
require_relative 'lib/shield.rb'
require_relative 'lib/reflect.rb'
require_relative 'lib/missile.rb'
require_relative 'lib/seppuku.rb'
require_relative 'lib/heavy_wounds.rb'
require_relative 'lib/sokushi.rb'
require_relative 'lib/next_sequence.rb'
require_relative 'lib/game.rb'
require 'io/console'
require 'pp'

game = Game.new
continue = true

def paralysis
  {
    :name => "Paralysis",
    :short => "violet (3x)",
    :command => "violet, violet, violet",
    :description => "Forces one wizard to repeat the hand sign he performed last turn. The target depends on which ninja executes the jutsu (left targets left, right targets right). Paralysis can only affect one ninja at a time. Some hand signs will be changed to another to prevent complete impairment (blue changes to violet, yellow to green, and indigo to red).",
    :countered_by => "CounterSpell, Reflect, UltimateDefense"
  }
end

def shield
  {
    :name => "Shield",
    :short => "red",
    :command => "red",
    :description => "Stops shock and missle damage from opponent's team for one turn.",
    :countered_by => nil
  }
end

def shock
  {
    :name => "Shock",
    :short => "orange",
    :command => "orange",
    :description => "Does one point of damage.",
    :countered_by => "Shield, UltimateDefense"
  }
end

def missile
  {
    :name => "Missile",
    :short => "yellow, green",
    :command => "yellow, green",
    :description => "Does one point of damage.",
    :countered_by => "Shield, Reflect, CounterSpell, UltimateDefense"
  }
end

def light_wound
  {
    :name => "Light Wounds",
    :short => "indigo, violet, red",
    :command => "indigo, violet, red (this jutsu will take three turns to execute, a wizard needs to execute indigo, then violet, then red)",
    :description => "Does two points of damage.",
    :countered_by => "Reflect, CounterSpell, UltimateDefense"
  }
end

def heavy_wound
  {
    :name => "Heavy Wounds",
    :short => "indigo, red, violet, green",
    :command => "indigo, red, violet, green (this jutsu will take four turns to execute, a wizard needs to execute indigo, then red, then violet, then green)",
    :description => "Does three points of damage.",
    :countered_by => "Reflect, CounterSpell, UltimateDefense"
  }
end

def lighting_bolt
  {
    :name => "Lightning Bolt",
    :short => "green, violet, violet, green, green",
    :command => "green, violet, violet, green, green (the last command doubles up as the first command if executed one after another)",
    :description => "Does five points of damage.",
    :countered_by => "Reflect, CounterSpell, UltimateDefense"
  }
end

def fast_lighting_bolt
  {
    :name => "Fast Lightning Bolt",
    :short => "indigo, green, green, [blue, blue] (once per game)",
    :command => "indigo, green, green, [blue, blue] (both wizard must cast the last sign for jutsu the to execute)",
    :description => "Does five points of damage. This jutsu can only be used once per match by each team.",
    :countered_by => "Reflect, CounterSpell, UltimateDefense"
  }
end

def seppuku
  {
    :name => "Seppuku",
    :short => "[orange, orange] or [red, red] (instant forfeit)",
    :command => "[orange, orange] or [red, red] (if both wizard on the team cast either orange or red, it's instant death for that team)",
    :description => "Curse does 30 points of damage to the team that casts the jutsu. Instant death.",
    :countered_by => nil
  }
end

def reflect
  {
    :name => "Reflect",
    :short => "[blue, blue], [indigo, indigo]",
    :command => "[blue, blue], [indigo, indigo] (both wizard must issue both commands in unison)",
    :description => "Reflects jutsu back at opponent. Will not reflect Shock however.",
    :countered_by => nil
  }
end

def counter_spell
  {
    :name => "Counter Spell",
    :short => "indigo, red, red or indigo, indigo, yellow",
    :command => "indigo, red, red or indigo, indigo, yellow",
    :description => "Nullifies all attack jutsu except Shock or Sokushi.",
    :countered_by => nil
  }
end

def ultimate_defense
  {
    :name => "Ultimate Defense",
    :short => "[blue, blue], green, red, indigo",
    :command => "[blue, blue], green, red, indigo",
    :description => "Nullifies all attack jutsu.",
    :countered_by => nil
  }
end

def sokushi
  {
    :name => "Sokushi",
    :short => "red, indigo, red, violet, yellow (3x), green",
    :command => "red, indigo, red, violet, yellow, yellow, yellow, green",
    :description => "Does 100 points of damage.",
    :countered_by => "UltimateDefense"
  }
end

def heal
  {
    :name => "Heal",
    :short => "green, violet, indigo",
    :command => "green, violet, indigo",
    :description => "Removes one point of damage.",
    :countered_by => nil
  }
end

def amnesia
  {
    :name => "Amnesia",
    :short => "green, red, red",
    :command => "green, red, red",
    :description => "When Amnesia is cast, opponent will be forced to repeat the same signs he performed before.",
    :countered_by => "Reflects, CounterSpell, UltimateDefense"
  }
end

def upheaval
  {
    :name => "Upheaval",
    :short => "yellow, red, violet",
    :command => "yellow, red, violet",
    :description => "When Upheaval is cast, opponent will have all of his sequences reset.",
    :countered_by => "Reflects, CounterSpell, UltimateDefense"
  }
end

def silence
  {
    :name => "Silence",
    :short => "yellow, indigo, green",
    :command => "yellow, indigo, green",
    :description => "Disables the opponents ability to cast blue, green, violet, yellow.",
    :countered_by => "Reflects, CounterSpell, UltimateDefense"
  }
end

def greater_heal
  {
    :name => "Greater Heal",
    :short => "green, violet, red, indigo",
    :command => "green, violet, red, indigo",
    :description => "Removes two points of damage.",
    :countered_by => nil
  }
end

current_turn = :player_1
turn = { player_1: { }, player_2: { } }

while continue
  if current_turn == :player_1
    puts 'Player 1, enter one of the commands below:'
    puts 'cast!, status, list'
  else
    puts 'Player 2, enter one of the commands below:'
    puts 'cast!, status, list'
  end

  text = STDIN.noecho(&:gets).chomp

  if text == 'status'
    puts 'Player 1 Left:'
    pp game.next_sequence_for_turn[game.current_turn][:a][:left][:by_command]
    pp game.next_sequence_for_turn[game.current_turn][:a][:left][:mins]
    puts 'Player 1 Right:'
    pp game.next_sequence_for_turn[game.current_turn][:a][:right][:by_command]
    pp game.next_sequence_for_turn[game.current_turn][:a][:right][:mins]
    puts 'Player 2 Left:'
    pp game.next_sequence_for_turn[game.current_turn][:a][:left][:by_command]
    pp game.next_sequence_for_turn[game.current_turn][:a][:left][:mins]
    puts 'Player 2 Right:'
    pp game.next_sequence_for_turn[game.current_turn][:a][:right][:by_command]
    pp game.next_sequence_for_turn[game.current_turn][:a][:right][:mins]
  elsif text == 'list'
    puts([shield])
  elsif text == 'cast!'
    casted = false
    mana_pool = :left

    while !casted
      if(mana_pool == :left)
        puts "What mana do you want to infuse for the LEFT spell? (roygbiv)"
        turn[current_turn][:left] = STDIN.noecho(&:gets).chomp
        mana_pool = :right
      else
        puts "What mana do you want to infuse for the Right spell? (roygbiv)"
        turn[current_turn][:right] = STDIN.noecho(&:gets).chomp
        casted = true
        if(current_turn == :player_1)
          current_turn = :player_2
        else
          pp turn
          current_turn = :player_1
        end
      end
    end
  elsif text == 'exit'
    continue = false
  end
end
