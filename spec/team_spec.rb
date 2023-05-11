require_relative "../app/team"

describe Team do
  let(:name) { Faker::Team.name }
  subject { described_class.new(name) }

  describe "new class" do
    it { is_expected.to be_a Team }
    it { expect(subject.name).to eq(name) }
    it { expect(subject.score).to be_nil }
    it { expect(subject.points).to be_zero }
    it { expect(subject.to_s).to eq("#{name}, 0 pts") }
  end

  describe "#match_results" do
    let(:home_team) { described_class.new("Home Team") }
    let(:away_team) { described_class.new("Away Team") }
    let(:match_results) { home_team.match_results(away_team) }

    context "when no scores recorded for home team" do
      it { expect { match_results }.to raise_error("Home Team hasn't played yet") }
    end

    context "when no scores recorded for away team" do
      before { home_team.record_score(0) }
      it { expect { match_results }.to raise_error("Away Team hasn't played yet") }
    end

    context "when home team won" do
      before do
        home_team.record_score(2)
        away_team.record_score(1)
        match_results
      end

      it { expect(home_team.to_s).to eq("Home Team, 3 pts") }
      it { expect(away_team.to_s).to eq("Away Team, 0 pts") }
      it { expect([away_team, home_team].sort).to eq([home_team, away_team]) }
      it { expect(home_team.score).to be_nil }
      it { expect(away_team.score).to be_nil }
    end

    context "when home team lost" do
      before do
        home_team.record_score(0)
        away_team.record_score(3)
        match_results
      end

      it { expect(home_team.to_s).to eq("Home Team, 0 pts") }
      it { expect(away_team.to_s).to eq("Away Team, 3 pts") }
      it { expect([home_team, away_team].sort).to eq([away_team, home_team]) }
      it { expect(home_team.score).to be_nil }
      it { expect(away_team.score).to be_nil }
    end

    context "when there is a draw" do
      before do
        home_team.record_score(4)
        away_team.record_score(4)
        match_results
      end

      it { expect(home_team.to_s).to eq("Home Team, 1 pt") }
      it { expect(away_team.to_s).to eq("Away Team, 1 pt") }
      it { expect([home_team, away_team].sort).to eq([away_team, home_team]) }
      it { expect(home_team.score).to be_nil }
      it { expect(away_team.score).to be_nil }
    end
  end

  describe "#record_win" do
    let(:name) { "Best Team" }

    it "should update points" do
      expect { subject.record_win }.to change { subject.points }.from(0).to(3)
      expect { subject.record_win }.to change { subject.points }.from(3).to(6)
      expect(subject.to_s).to eq("Best Team, 6 pts")
    end
  end

  describe "#record_draw" do
    let(:name) { "Best Team" }

    it "should update points" do
      expect { subject.record_draw }.to change { subject.points }.from(0).to(1)
      expect(subject.to_s).to eq("Best Team, 1 pt")
    end
  end

  describe "#record_score" do
    let(:score) { Faker::Number.number(digits: 2) }
    let(:record_score) { subject.record_score(score) }
    it { expect { record_score }.to change { subject.score }.from(nil).to(score) }
  end

  describe "#reset_scores" do
    let(:score) { Faker::Number.number(digits: 2) }
    before { subject.record_score(score) }
    it { expect { subject.reset_scores }.to change { subject.score }.from(score).to(nil) }
  end
end
