require 'rails_helper'

RSpec.describe External::CoursesController, type: :request do
  let(:given_course_info) {
    {
      course_uuid:    SecureRandom.uuid.to_s,
      ecosystem_uuid: SecureRandom.uuid.to_s,
      is_real_course: [ true, false ].sample,
      starts_at:      Time.current.iso8601(6),
      ends_at:        Time.current.tomorrow.iso8601(6),
      created_at:     Time.current.yesterday.iso8601(6),
    }
  }

  let(:request_payload) { given_course_info }

  let(:process_payload) { given_course_info }

  let(:process_result) { {created_course_uuid: given_course_info[:course_uuid]} }

  let(:target_response) { process_result }

  let(:service_double) {
    object_double(Services::CreateCourse::Service.new).tap do |dbl|
      allow(dbl).to receive(:process).with(process_payload).and_return(process_result)
    end
  }

  before(:each) do
    allow(Services::CreateCourse::Service).to receive(:new).and_return(service_double)
  end

  context "course creation" do
    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = create_course(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = create_course(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the CreateCourses service is called with the correct response data" do
        response_status, response_body = create_course(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = create_course(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  context "start/end date update" do

  end

  protected

  def create_course(request_payload:)
    make_post_request(
      route:   '/create_course',
      headers: { 'Content-Type' => 'application/json' },
      body:    request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

end
