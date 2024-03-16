class JourneyRun < ApplicationRecord
  belongs_to :journey
  belongs_to :run
end
