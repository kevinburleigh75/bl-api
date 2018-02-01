require 'rails_helper'

RSpec.describe Services::UpdateCourseEcosystem::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(update_requests: given_update_data) }

  let(:given_course_events) {
    given_update_data.map{ |update_data|
      CourseEvent.new(
        event_uuid:             update_data.fetch(:request_uuid),
        event_type:             CourseEvent.event_type.update_course_ecosystem,
        course_uuid:            update_data.fetch(:course_uuid),
        course_seqnum:          update_data.fetch(:sequence_number),
        event_has_been_bundled: false,
        event_data: update_data.slice(
          :request_uuid,
          :course_uuid,
          :sequence_number,
          :preparation_uuid,
          :updated_at,
        ),
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

  before(:each) do
    allow(Utils::RecordCourseEvents::Util).to receive(:new).and_return(service_double)
  end

  context "when no update requests are given" do
    let(:given_update_data) { [] }

    it "the RecordCourseEvents service is called with the correct CourseEvents" do
      action
      expect(service_double).to have_received(:process).with(the_same_records_as(process_payload))
    end

    it "the returned update_statuses array is empty" do
      expect(action.fetch(:update_statuses)).to be_empty
    end
  end

end
