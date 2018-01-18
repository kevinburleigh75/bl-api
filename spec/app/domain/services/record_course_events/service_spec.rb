require 'rails_helper'

RSpec.describe Services::RecordCourseEvents::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(course_events: given_course_events) }

  context "no CourseEvents are given" do
    let(:given_course_events) { [] }

    it "no CourseEvents are created" do
      expect{action}.to_not change{CourseEvent.count}
    end

    it "an empty uuid array is returned" do
      expect(action).to be_empty
    end
  end

  context "when CourseEvents are given" do
    let(:event_data) do
      4.times.map do
        {
          event_uuid:         SecureRandom.uuid.to_s,
          event_type:         CourseEvent.event_type.values.sample,
          course_uuid:        SecureRandom.uuid.to_s,
          course_seqnum:      Kernel.rand(1000),
          has_been_processed: [ true, false ].sample,
          data: {
            key1: SecureRandom.uuid.to_s,
            key2: Kernel.rand(1000),
            key3: Time.now.iso8601(6),
          },
        }
      end
    end

    let(:existing_event_data) { event_data.values_at(0, 2) }
    let(:new_event_data)      { event_data.values_at(1, 3) }

    let(:given_event_data)    { event_data * 2 }

    let!(:existing_course_events) {
      existing_event_data.map{ |event_data| FactoryBot.create(:course_event, event_data) }
    }

    let(:given_course_events) {
      given_event_data.map{ |event_data| FactoryBot.build(:course_event, event_data) }
    }

    it "CourseEvents are created for only previously-unseen events" do
      expect{action}.to change{CourseEvent.count}.by(new_event_data.size)

      target_event_uuids   = new_event_data.map{ |data| data.fetch(:event_uuid) }
      newly_created_events = CourseEvent.where(event_uuid: target_event_uuids)
      expect(newly_created_events.size).to eq(new_event_data.size)
    end

    it "previously-seen CourseEvents are left unchanged" do
      expect(existing_course_events.size).to eq(existing_event_data.size)
      target_updated_at_by_uuid = existing_course_events.inject({}) { |result, event|
        result[event.event_uuid] = event.updated_at
        result
      }

      action

      existing_course_events.each do |event|
        event.reload
        expect(target_updated_at_by_uuid[event.event_uuid]).to eq(event.updated_at)
      end
    end

    it "all unique given event_uuids are returned (idempotence)" do
      target_uuids = given_event_data.map{ |data| data.fetch(:event_uuid) }.uniq
      expect(action).to match_array(target_uuids)
    end

    it 'the newly-created CourseEvent records have the correct parameters' do
      expect{action}.to change{CourseEvent.count}.by(new_event_data.size)

      new_event_uuids = new_event_data.map{ |data| data.fetch(:event_uuid) }
      newly_created_events = CourseEvent.where(event_uuid: new_event_uuids)

      given_event_data_by_event_uuid = given_event_data.index_by{ |event| event.fetch(:event_uuid) }

      newly_created_events.each do |newly_created_event|
        given_event_data = given_event_data_by_event_uuid[newly_created_event.event_uuid]

        aggregate_failures 'data checks' do
          expect(newly_created_event.event_uuid).to eq(given_event_data.fetch(:event_uuid))
          expect(newly_created_event.event_type).to eq(given_event_data.fetch(:event_type))
          expect(newly_created_event.course_uuid).to eq(given_event_data.fetch(:course_uuid))
          expect(newly_created_event.course_seqnum).to(eq(given_event_data.fetch(:course_seqnum)))

          data = newly_created_event.data.deep_symbolize_keys
          expect(data.fetch(:key1)).to eq(given_event_data.fetch(:data).fetch(:key1))
          expect(data.fetch(:key2)).to eq(given_event_data.fetch(:data).fetch(:key2))
          expect(data.fetch(:key3)).to eq(given_event_data.fetch(:data).fetch(:key3))
        end
      end
    end
  end
end
