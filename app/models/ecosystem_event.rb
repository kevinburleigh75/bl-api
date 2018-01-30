class EcosystemEvent < ApplicationRecord
  extend Enumerize

  enumerize :event_type, in: [
    :create_ecosystem,
  ]

  validates :ecosystem_seqnum, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
