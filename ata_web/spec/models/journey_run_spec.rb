require 'rails_helper'

RSpec.describe JourneyRun, type: :model do
  describe ".to_csv" do
    context "errors" do
      let(:error) do
        catch(:invalid_input) do
          described_class.to_csv(from: from_date, to: to_date, ltn: Ltn.find(1))
        end
      end

      context "asking for more than one month" do
        let(:from_date) { Date.new(2025, 1, 1) }
        let(:to_date) { Date.new(2025, 2, 2) }

        it "can only get 1 month at a time" do
          expect(error).to eq "Can only ask for 1 month of data at a time"
        end
      end

      context "from date is before to date" do
        let(:from_date) { Date.new(2025, 2, 2) }
        let(:to_date) { Date.new(2025, 2, 1) }

        it "can only get 1 month at a time" do
          expect(error).to eq "From: '2025-02-02' must be before To: '2025-02-01'"
        end
      end
    end

    context "without overview_polyline" do
      it do
        csv = described_class.to_csv(from: Date.new(2021, 3, 24), to: Date.new(2021, 3, 26), ltn: Ltn.find(1))
        parsed = CSV.parse(csv, headers: true)
        expect(parsed.headers).to eq [
          "scheme", "mode", "journey_id", "origin_lat", "origin_lng", "dest_lat", "dest_lng",
          "run_id", "duration", "duration_in_traffic", "distance", "created_at"
        ]
        first = parsed.first
        aggregate_failures do
          expect(first["scheme"]).to eq "testing"
          expect(first["mode"]).to eq "driving"
          expect(first["journey_id"]).to eq "1"
          expect(first["origin_lat"]).to eq "51.444084"
          expect(first["origin_lng"]).to eq "-0.08521915"
          expect(first["dest_lat"]).to eq "51.451654"
          expect(first["dest_lng"]).to eq "-0.09603918"
          expect(first["run_id"]).to eq "1020"
          expect(first["duration"]).to eq "204"
          expect(first["duration_in_traffic"]).to eq "258"
          expect(first["distance"]).to eq "1260"
        end
      end
    end

    context "with overview_polyline" do
      it do
        csv = described_class.to_csv(from: Date.new(2021, 3, 24), to: Date.new(2021, 3, 26), ltn: Ltn.find(1), overview_polyline: true)
        parsed = CSV.parse(csv, headers: true)
        expect(parsed.headers).to eq [
          "scheme", "mode", "journey_id", "origin_lat", "origin_lng", "dest_lat", "dest_lng",
          "run_id", "duration", "duration_in_traffic", "distance", "created_at", "overview_polyline"
        ]
        expect(parsed.first["overview_polyline"]).to eq described_class.first.overview_polyline.to_s

      end
    end
  end
end
