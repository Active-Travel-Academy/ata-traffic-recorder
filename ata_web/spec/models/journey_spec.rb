require 'rails_helper'

RSpec.describe Journey, type: :model do

  it "trims name" do
    journey = Journey.new(name: " a"*200)
    expect(journey.name[0,3]).to eq " a "
    journey.run_callbacks(:save)
    expect(journey.name.size).to eq 250
    expect(journey.name[0,3]).to eq "a a"
  end

  describe ".create_from_csv" do
    let(:create_from_csv) do
      described_class.create_from_csv(
        fixture_file_upload(file_fixture(file_name), :csv), scheme
      )
    end
    let(:mime_type) { :csv }
    let(:scheme) { ltns(:Ltn_1) }

    context "with a good csv" do
      let(:file_name) { "journeys_upload_good.csv" }
      it do
        expect { create_from_csv }.to change { scheme.journeys.count }.by(2)
        expect(scheme.journeys.last(2).map(&:name)).to match_array ["fly me to the moon", nil]
      end
    end
  end
end
