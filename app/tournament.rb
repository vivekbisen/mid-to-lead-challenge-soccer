require "set"
require_relative "team"

class Tournament
  attr_reader :teams, :teams_played_today, :matchday

  def initialize
    @teams = {}
    @matchday = 1
    @teams_played_today = SortedSet.new
  end

  def self.run(input_file)
    tournament = new
    if input_file
      tournament.process_file(input_file)
    else
      loop do
        game_result = gets
        tournament.process_result(game_result)
      end
    end
  end

  def process_file(filename)
    File.foreach(filename) do |line|
      process_result(line)
    end

    process_result(nil)
  end

  def process_result(result)
    return end_of_day if result == "\n"
    return unless valid?(result)

    home_team_raw, away_team_raw = result.split(",")
    home_team = find_or_initialize_team(home_team_raw)
    away_team = find_or_initialize_team(away_team_raw)

    increment_matchday([home_team, away_team])
    home_team.match_results(away_team)
  end

  def end_of_day
    increment_matchday([], true)
  end

  private

  attr_writer :matchday

  def valid?(result)
    result =~ /^[a-zA-Z\s]+\d+,[a-zA-Z\s]+\d+$/
  end

  def increment_matchday(teams, eod = false)
    same_day = teams.reduce(true) do |value, team|
      value && teams_played_today.add?(team)
    end
    next_day = !same_day || eod

    if next_day && teams_played_today.any?
      output = output_message(teams_played_today.first(3))
      send_output(output)

      teams_played_today.clear
      self.matchday += 1
    end
    teams.each { |team| teams_played_today.add(team) }
  end

  def output_message(teams)
    return "" if teams.empty?

    <<~HEREDOC
      Matchday #{matchday}
      #{teams.map(&:to_s).join("\n")}

    HEREDOC
  end

  def send_output(output)
    return if output.empty?

    puts output
  end

  def name(team_line)
    team_line.split[0..-2].join(" ")
  end

  def score(team_line)
    team_line.split.last.to_i
  end

  def find_or_initialize_team(team_line)
    name = name(team_line)
    teams[name] ||= Team.new(name)
    teams[name].record_score(score(team_line))
    teams[name]
  end
end
