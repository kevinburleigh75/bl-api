require 'rails_helper'

RSpec.describe Services::CreateEcosystem::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(ecosystem_info: given_ecosystem_info) }

  let(:given_ecosystem_info) {
    {
      ecosystem_uuid: SecureRandom.uuid.to_s,
      book: {
        cnx_identity: "#{SecureRandom.uuid}@#{rand(99) + 1}.#{rand(99) + 1}",
        contents:     book_contents
      },
      exercises:   book_exercise_infos,
      imported_at: Time.current.iso8601(6),
    }
  }

  let(:book_contents) { book_chapters + book_pages }

  let(:book_chapters) {
    2.times.map{
      {
        container_uuid:         SecureRandom.uuid,
        container_parent_uuid:  nil,
        container_cnx_identity: "#{SecureRandom.uuid}@#{rand(99) + 1}.#{rand(99) + 1}",
        pools: [
          {
            use_for_clue:                              true,
            use_for_personalized_for_assignment_types: [],
            exercise_uuids: book_exercise_infos.sample(4).map{ |exercise_info|
              exercise_info.fetch(:uuid)
            }
          }
        ]
      }
    }
  }

  let(:book_pages) {
    assignment_types = ['homework', 'reading', 'concept-coach']

    4.times.map{
      {
        container_uuid:         SecureRandom.uuid,
        container_parent_uuid:  book_chapters.sample.fetch(:container_uuid),
        container_cnx_identity: "#{SecureRandom.uuid}@#{rand(99) + 1}.#{rand(99) + 1}",
        pools: 3.times.map{
          {
            use_for_clue:                              [true, false].sample,
            use_for_personalized_for_assignment_types: assignment_types.sample(2),
            exercise_uuids: book_exercise_infos.sample(3).map{ |exercise_info|
              exercise_info.fetch(:uuid)
            }
          }
        }
      }
    }
  }

  let(:book_exercise_infos) {
    6.times.map{
      {
        uuid:              SecureRandom.uuid.to_s,
        exercises_uuid:    SecureRandom.uuid.to_s,
        exercises_version: rand(10),
        los:               5.times.map{ SecureRandom.uuid.to_s }
      }
    }
  }

  let(:given_ecosystem_event) {
    EcosystemEvent.new(
      event_uuid:             given_ecosystem_info.fetch(:ecosystem_uuid),
      event_type:             EcosystemEvent.event_type.create_ecosystem,
      ecosystem_uuid:         given_ecosystem_info.fetch(:ecosystem_uuid),
      ecosystem_seqnum:       0,
      event_has_been_bundled: false,
      event_data: given_ecosystem_info.slice(
        :ecosystem_uuid,
        :book,
        :exercises,
        :imported_at,
      ),
    )
  }

  let(:process_payload) { {ecosystem_events: [given_ecosystem_event]} }
  let(:process_result)  { [given_ecosystem_event.event_uuid] }

  let(:service_double) {
    object_double(Services::RecordEcosystemEvents::Service.new).tap do |dbl|
      allow(dbl).to receive(:process).and_return(process_result)
    end
  }

  before(:each) do
    allow(Services::RecordEcosystemEvents::Service).to receive(:new).and_return(service_double)
  end

  it "the RecordEcosystemEvents service is called with the correct EcosystemEvent" do
    action
    expect(service_double).to have_received(:process).with(the_same_records_as(process_payload))
  end

  it "the uuid returned from the RecordEcosystemEvents service is properly returned" do
    expect(action.fetch(:created_ecosystem_uuid)).to eq(given_ecosystem_info.fetch(:ecosystem_uuid))
  end
end
