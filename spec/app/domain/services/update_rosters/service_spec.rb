require 'rails_helper'

RSpec.describe Services::UpdateRosters::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(rosters: given_roster_data) }

  let(:given_course_events) {
    given_roster_data.map{ |roster_data|
      CourseEvent.new(
        event_uuid:             roster_data.fetch(:request_uuid),
        event_type:             CourseEvent.event_type.update_roster,
        course_uuid:            roster_data.fetch(:course_uuid),
        course_seqnum:          roster_data.fetch(:sequence_number),
        event_has_been_bundled: false,
        event_data: roster_data.slice(
          :request_uuid,
          :course_uuid,
          :sequence_number,
          :course_containers,
          :students,
        ),
      )
    }
  }

  let(:process_payload) { {course_events: given_course_events} }
  let(:process_result)  { given_course_events.map{|event| event.event_uuid} }

  let(:utility_double) {
    object_double(Utils::RecordCourseEvents::Util.new).tap do |dbl|
      allow(dbl).to receive(:process).and_return(process_result)
    end
  }

  let(:target_response) {
    {
      updated_rosters: given_roster_data.map{ |roster|
        {
          request_uuid:        roster.fetch(:request_uuid),
          updated_course_uuid: roster.fetch(:course_uuid),
        }
      }
    }
  }

  before(:each) do
    allow(Utils::RecordCourseEvents::Util).to receive(:new).and_return(utility_double)
  end

  context "when no roster data is given" do
    let(:given_roster_data) { [] }

    it "the RecordCourseEvents service is called with the correct CourseEvents" do
      action
      expect(utility_double).to have_received(:process).with(the_same_records_as(process_payload))
    end

    it "the returned result array is empty" do
      expect(action).to match_array(target_response)
    end
  end

  context "when roster data is given" do
    let(:given_roster_data) {
      1.times.map{
        {
          request_uuid:      SecureRandom.uuid.to_s,
          course_uuid:       SecureRandom.uuid.to_s,
          sequence_number:   Kernel.rand(10),
          course_containers: [
            {
              container_uuid:        SecureRandom.uuid.to_s,
              parent_container_uuid: SecureRandom.uuid.to_s,
              created_at:            Time.current.iso8601(6),
              archived_at:           Time.current.iso8601(6),
            }
          ],
          students: [
            student_uuid:                    SecureRandom.uuid.to_s,
            container_uuid:                  SecureRandom.uuid.to_s,
            enrolled_at:                     Time.current.iso8601(6),
            last_course_container_change_at: Time.current.iso8601(6),
            dropped_at:                      Time.current.iso8601(6),
          ],
        }
      }
    }

    it "the RecordCourseEvents utility is called with the correct CourseEvents" do
      action
      expect(utility_double).to have_received(:process).with(the_same_records_as(process_payload))
    end

    it "the correct result array is returned" do
      expect(action).to match_array(target_response)
    end
  end

end
