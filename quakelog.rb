class QuakeLog
  attr_accessor :file_path

  def initialize
    @game_count = 0
    @total_kills = 0
    @game_count_str = "game_0"
    @kills_hash = {@game_count_str => {"total_kills" => 0,"players" => [],"kills" => {}}}
    @kill_means_hash = {@game_count_str => {"kills_by_means" => {}} }
    @all_kill_count_info = []
    @all_kill_means_info = []
  end

  def get_kill_info(line)
    "
    Returns killer, killed player and death cause for each kill.
    "
    words_before, words_after = line.split(/\s*killed\s*/).map do |t|
      t.split(/\s+/)
    end
    killer_player = words_before[6..-1].join(" ")
    killed_player = words_after[0..-3].join(" ")
    death_cause = words_after[-1]

    return killer_player, killed_player, death_cause
  end

  def count_kills(file_path)
    initialize
    File.readlines(file_path).each do |line|
      if line[/InitGame/]  #New game started
        @total_kills = 0
        @game_count += 1
        @game_count_str = "game_" + @game_count.to_s
        @kills_hash = {@game_count_str => {"total_kills" => 0,"players" => [],"kills" => {}}}
      end
      if (line[/Kill/])
        @total_kills += 1
        killer_player, killed_player, _ = self.get_kill_info(line)
        if killer_player != "<world>"
          if ! @kills_hash[@game_count_str]["kills"].key?(killer_player)
            @kills_hash[@game_count_str]["players"].append(killer_player)
            @kills_hash[@game_count_str]["kills"][killer_player] = 1
          else
            @kills_hash[@game_count_str]["kills"][killer_player] += 1
          end
        else
          if ! @kills_hash[@game_count_str]["kills"].key?(killed_player)
            @kills_hash[@game_count_str]["players"].append(killed_player)
            @kills_hash[@game_count_str]["kills"][killed_player] = -1
          else
            @kills_hash[@game_count_str]["kills"][killed_player] -= 1
          end
        end
      end
      if line[/ShutdownGame/] #Game shutdown
        @kills_hash[@game_count_str]["total_kills"] = @total_kills
        puts @kills_hash
        puts "----------------------------------"
        puts "Player rankings for " + @game_count_str + ": "
        puts @kills_hash[@game_count_str]["kills"].sort_by {|_key, value| value}.reverse
        @all_kill_count_info.append(@kills_hash)
        puts "----------------------------------"
      end
    end
    return @all_kill_count_info
  end

  def count_kill_means(file_path)
    initialize
    File.readlines(file_path).each do |line|
      if line[/InitGame/]  #New game started
        @total_kills = 0
        @game_count += 1
        @game_count_str = "game_" + @game_count.to_s
        @kill_means_hash = {@game_count_str => {"kills_by_means" => {}} }
      end
      if (line[/Kill/])
        @total_kills += 1
        _, _, death_cause = self.get_kill_info(line)
        if !@kill_means_hash[@game_count_str]["kills_by_means"].key?(death_cause)
          @kill_means_hash[@game_count_str]["kills_by_means"][death_cause] = 1
        else
          @kill_means_hash[@game_count_str]["kills_by_means"][death_cause] += 1
        end
      end
      if line[/ShutdownGame/] #Game shutdown
        puts @kill_means_hash
        @all_kill_means_info.append(@kill_means_hash)
      end
    end
    return @all_kill_means_info
  end
end