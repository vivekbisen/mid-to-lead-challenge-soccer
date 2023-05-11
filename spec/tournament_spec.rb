require_relative "../app/tournament"

describe Tournament do
  describe "new class" do
    it { is_expected.to be_a Tournament }
    it { expect(subject.teams).to be_a(Hash).and(be_empty) }
    it { expect(subject.matchday).to eq(1) }
    it { expect(subject.teams_played_today).to be_a(SortedSet).and(be_empty) }
  end

  describe ".run" do
    after { described_class.run(input_file) }
    context "when there is an input file" do
      let(:input_file) { double }
      it { expect_any_instance_of(Tournament).to receive(:process_file).with(input_file).once }
    end
  end

  describe "process_file" do
    let(:filename) { "sample-input.txt" }
    before { allow(subject).to receive(:process_result) }
    after { subject.process_file(filename) }
    it { is_expected.to receive(:process_result).at_least(:twice) }
  end

  describe "process_result" do
    context "when result is new line" do
      after { subject.process_result("\n") }
      it { is_expected.to receive(:end_of_day) }
    end

    context "when result is invalid" do
      it { expect(subject.process_result("asdsa\as,dnasda")).to be_nil }
    end

    context "when result is valid" do
      let(:result) { "Team A 1, Team B 0" }
      let(:teams) { {"Team A" => a_kind_of(Team), "Team B" => a_kind_of(Team)} }

      before { subject.process_result(result) }
      it { expect(subject.teams).to include(teams) }
      it { expect(subject.teams_played_today).to match_array([a_kind_of(Team)] * 2) }
      it { expect(subject.matchday).to eq(1) }
      it { expect(subject.teams["Team A"].points).to eq(3) }
      it { expect(subject.teams["Team B"].points).to eq(0) }
    end
  end

  describe "end_of_day" do
    after { subject.end_of_day }
    it { is_expected.to receive(:increment_matchday).with([], true) }
  end
end
