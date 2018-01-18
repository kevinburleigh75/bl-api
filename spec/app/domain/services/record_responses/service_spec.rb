require 'rails_helper'

RSpec::Matchers.define :the_same_records_as do |expected|
  match do |actual|
    ## same keys
    result = expected.keys.sort == actual.keys.sort
    break result unless result

    ## for each key
    result = expected.keys.each do |key|
      ## same number of values
      expected_records = expected[key]
      actual_records   = actual[key]
      break false if expected_records.count != actual_records.count

      ## same values (order doesn't matter)
      result = expected_records.each do |expected_record|
        break false unless actual_records.detect{|actual_record| actual_record.attributes == expected_record.attributes}
        true
      end
      break result unless result
    end
    result
  end
end

RSpec.describe Services::RecordResponses::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(responses: given_response_data, other: process_payload) }

  let(:given_course_events) {
    given_response_data.map{ |response_data|
      CourseEvent.new(
        event_uuid:         response_data.fetch(:response_uuid),
        event_type:         CourseEvent.event_type.record_response,
        course_uuid:        response_data.fetch(:course_uuid),
        course_seqnum:      response_data.fetch(:sequence_number),
        has_been_processed: false,
        data: response_data.slice(
          :response_uuid,
          :course_uuid,
          :sequence_number,
          :ecosystem_uuid,
          :trial_uuid,
          :student_uuid,
          :exercise_uuid,
          :is_correct,
          :is_real_response,
          :responded_at,
        ),
      )
    }
  }

  let(:process_payload) { {course_events: given_course_events} }
  let(:process_result)  { given_course_events.map{|event| event.event_uuid} }

  let(:service_double) {
    object_double(Services::RecordCourseEvents::Service.new).tap do |dbl|
      allow(dbl).to receive(:process).and_return(process_result)
    end
  }

  before(:each) do
    allow(Services::RecordCourseEvents::Service).to receive(:new).and_return(service_double)
  end

  context "when no response data is given" do
    let(:given_response_data) { [] }

    it "the RecordCourseEvents service is called with the correct CourseEvents" do
      action
      expect(service_double).to have_received(:process).with(the_same_records_as(process_payload))
    end

    it "the RecordCourseEvents service is called with the correct CourseEvents" do
      expect(action.fetch(:recorded_response_uuids)).to match_array(process_result)
    end
  end

  context "when response data is given" do
    let(:given_response_data) {
      1.times.map{
        {
          response_uuid:    SecureRandom.uuid.to_s,
          course_uuid:      SecureRandom.uuid.to_s,
          sequence_number:  Kernel.rand(1000),
          ecosystem_uuid:   SecureRandom.uuid.to_s,
          trial_uuid:       SecureRandom.uuid.to_s,
          student_uuid:     SecureRandom.uuid.to_s,
          exercise_uuid:    SecureRandom.uuid.to_s,
          is_correct:       [ true, false ].sample,
          is_real_response: [ true, false ].sample,
          responded_at:     Time.current.iso8601(6),
        }
      }
    }

    it "the RecordCourseEvents service is called with the correct CourseEvents" do
      action
      expect(service_double).to have_received(:process).with(the_same_records_as(process_payload))
    end

    it "the uuids returned from the RecordCourseEvents service are properly returned" do
      expect(action.fetch(:recorded_response_uuids)).to match_array(process_result)
    end
  end
end
