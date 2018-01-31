require 'rails_helper'

RSpec.describe Services::CreateUpdateAssignments::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(assignments: given_assignment_data) }

  let(:given_course_events) {
    given_assignment_data.map{ |assignment|
      CourseEvent.new(
        event_uuid:    assignment.fetch(:request_uuid),
        event_type:    CourseEvent.event_type.create_update_assignment,
        course_uuid:   assignment.fetch(:course_uuid),
        course_seqnum: assignment.fetch(:sequence_number),
        event_data: assignment.slice(
          :request_uuid,
          :course_uuid,
          :sequence_number,
          :assignment_uuid,
          :is_deleted,
          :ecosystem_uuid,
          :student_uuid,
          :assignment_type,
          :exclusion_info,
          :assigned_book_container_uuids,
          :goal_num_tutor_assigned_spes,
          :spes_are_assigned,
          :goal_num_tutor_assigned_pes,
          :pes_are_assigned,
          :assigned_exercises,
          :created_at,
          :updated_at,
        )
      )
    }
  }

  let(:process_payload) { {course_events: given_course_events} }
  let(:process_result)  { given_course_events.map{|event| event.event_uuid} }

  let(:service_double) {
    object_double(Utils::RecordCourseEvents::Util.new).tap do |dbl|
      allow(dbl).to receive(:process).and_return(process_result)
    end
  }

  let(:target_result) {
    {
      updated_assignments: given_assignment_data.map{ |assignment|
        {
          request_uuid:    assignment.fetch(:request_uuid),
          assignment_uuid: assignment.fetch(:assignment_uuid),
        }
      }
    }
  }

  before(:each) do
    allow(Utils::RecordCourseEvents::Util).to receive(:new).and_return(service_double)
  end

  context "when no assignment data is given" do
    let(:given_assignment_data) { [] }

    it "the RecordCourseEvents service is called with the correct CourseEvents" do
      action
      expect(service_double).to have_received(:process).with(the_same_records_as(process_payload))
    end

    it "the returned updated assignments array is empty" do
      expect(action.fetch(:updated_assignments)).to be_empty
    end
  end

  context "when response data is given" do
    let(:given_assignment_data) do
      1.times.map{
        {
          request_uuid:                  SecureRandom.uuid.to_s,
          course_uuid:                   SecureRandom.uuid.to_s,
          sequence_number:               Kernel.rand(10),
          assignment_uuid:               SecureRandom.uuid.to_s,
          is_deleted:                    [true, false].sample,
          ecosystem_uuid:                SecureRandom.uuid.to_s,
          student_uuid:                  SecureRandom.uuid.to_s,
          assignment_type:               'some assignment type',
          assigned_book_container_uuids: [SecureRandom.uuid.to_s, SecureRandom.uuid.to_s],
          goal_num_tutor_assigned_spes:  Kernel.rand(10),
          spes_are_assigned:             [true, false].sample,
          goal_num_tutor_assigned_pes:   Kernel.rand(10),
          pes_are_assigned:              [true, false].sample,
          assigned_exercises: [
            {
              trial_uuid:    SecureRandom.uuid.to_s,
              exercise_uuid: SecureRandom.uuid.to_s,
              is_spe:        [true, false].sample,
              is_pe:         [true, false].sample,
            }
          ],
          created_at:                    Time.current.iso8601(6),
          updated_at:                    Time.current.iso8601(6),
        }
      }
    end

    it "the RecordCourseEvents service is called with the correct CourseEvents" do
      action
      expect(service_double).to have_received(:process).with(the_same_records_as(process_payload))
    end

    it "the array of updated assignment hashes is returned" do
      expect(action).to eq(target_result)
    end
  end
end
