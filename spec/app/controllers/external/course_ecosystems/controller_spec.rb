require 'rails_helper'

RSpec.describe External::CourseEcosystemsController, type: :request do
  context "ecosystem preparation" do
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

    let(:request_payload) { given_preparation_data }

    let(:process_payload) { {preparation_info: given_preparation_data} }
    let(:process_result)  { target_response }

    let(:target_response) { {status: 'accepted'} }

    let(:service_double) {
      object_double(Services::PrepareCourseEcosystem::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).and_return(process_result)
      end
    }

    before(:each) do
      allow(Services::PrepareCourseEcosystem::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = prepare_course_ecosystem(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = prepare_course_ecosystem(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the CreateCourses service is called with the correct response data" do
        response_status, response_body = prepare_course_ecosystem(request_payload: request_payload)
        expect(service_double).to have_received(:process).with(process_payload)
      end

      it "the response contains the target_response" do
        response_status, response_body = prepare_course_ecosystem(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  protected

  def prepare_course_ecosystem(request_payload:)
    make_post_request(
      route:   '/prepare_course_ecosystem',
      headers: { 'Content-Type' => 'application/json' },
      body:    request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

end
