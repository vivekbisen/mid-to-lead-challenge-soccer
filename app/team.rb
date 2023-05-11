class Team
  attr_reader :name, :score, :points

  def initialize(name)
    @name = name
    @score = nil
    @points = 0
  end

  def match_results(other_team)
    raise "#{name} hasn't played yet" unless score
    raise "#{other_team.name} hasn't played yet" unless other_team.score

    if won?(other_team)
      record_win
    elsif lost?(other_team)
      other_team.record_win
    elsif draw?(other_team)
      record_draw
      other_team.record_draw
    end

    reset_scores
    other_team.reset_scores
  end

  def record_win
    self.points += 3
  end

  def record_draw
    self.points += 1
  end

  def record_score(num)
    self.score = num
  end

  def reset_scores
    self.score = nil
  end

  # This combined comparison operator is used for sorting.
  # Tournament uses a SortedSet of teams to display winning teams in order
  # Sort the teams by points, or ascending name if points are same
  def <=>(other)
    if other.points == points
      name <=> other.name
    else
      other.points <=> points
    end
  end

  def to_s
    "#{name}, #{points} #{(points == 1) ? "pt" : "pts"}"
  end

  private

  attr_writer :score, :points

  def won?(other_team)
    score > other_team.score
  end

  def lost?(other_team)
    score < other_team.score
  end

  def draw?(other_team)
    score == other_team.score
  end
end
