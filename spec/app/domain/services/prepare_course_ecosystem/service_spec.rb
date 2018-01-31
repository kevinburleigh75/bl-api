require 'rails_helper'

RSpec.describe Services::PrepareCourseEcosystem::Service do
  context "basic functionality" do
    let(:service) { described_class.new }

    let(:action)  { service.process(preparation_info: given_preparation_data) }

    let(:given_preparation_data) {
      {
        preparation_uuid:    SecureRandom.uuid.to_s,
        course_uuid:         SecureRandom.uuid.to_s,
        sequence_number:     Kernel.rand(10),
        next_ecosystem_uuid: SecureRandom.uuid.to_s,
        ecosystem_map: {
          from_ecosystem_uuid: SecureRandom.uuid.to_s,
          to_ecosystem_uuid:   SecureRandom.uuid.to_s,
          book_container_mappings: [
            {
              from_book_container_uuid: SecureRandom.uuid.to_s,
              to_book_container_uuid:   SecureRandom.uuid.to_s,
            },
          ],
          exercise_mappings: [
            {
              from_exercise_uuid:     SecureRandom.uuid.to_s,
              to_book_container_uuid: SecureRandom.uuid.to_s,
            },
          ],
        },
        prepared_at:         Time.current.iso8601(6),
      }
    }

    let(:given_course_events) {
      [
        CourseEvent.new(
          event_uuid:             given_preparation_data.fetch(:preparation_uuid),
          event_type:             CourseEvent.event_type.update_course_ecosystem,
          course_uuid:            given_preparation_data.fetch(:course_uuid),
          course_seqnum:          given_preparation_data.fetch(:sequence_number),
          event_has_been_bundled: false,
          event_data: given_preparation_data.slice(
            :preparation_uuid,
            :course_uuid,
            :sequence_number,
            :ecosystem_map,
            :exercise_mappings,
            :prepared_at,
          ),
        )
      ]
    }

    let(:process_payload) { {course_events: given_course_events} }
    let(:process_result)  { given_course_events.map{|event| event.event_uuid} }

    let(:service_double) {
      object_double(Utils::RecordCourseEvents::Util.new).tap do |dbl|
        allow(dbl).to receive(:process).and_return(process_result)
      end
    }

    before(:each) do
      allow(Utils::RecordCourseEvents::Util).to receive(:new).and_return(service_double)
    end

    it "the RecordCourseEvents service is called with the correct CourseEvents" do
      action
      expect(service_double).to have_received(:process).with(the_same_records_as(process_payload))
    end

    it "the returned status is 'accepted'" do
      expect(action.fetch(:status)).to eq('accepted')
    end
  end
end

