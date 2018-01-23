require 'rails_helper'

RSpec.describe External::ResponsesController, type: :request do
  context 'basic functionality' do
    let(:given_responses) {
      1.times.map {
        {
          response_uuid:    SecureRandom.uuid,
          course_uuid:      SecureRandom.uuid,
          sequence_number:  Kernel.rand(10),
          ecosystem_uuid:   SecureRandom.uuid,
          trial_uuid:       SecureRandom.uuid,
          student_uuid:     SecureRandom.uuid,
          exercise_uuid:    SecureRandom.uuid,
          is_correct:       [ true, false ].sample,
          is_real_response: [ true, false ].sample,
          responded_at:     Time.current.iso8601(6),
        }
      }
    }

    let(:request_payload) { {responses: given_responses} }

    let(:process_payload) { {responses: given_responses} }

    let(:process_result) {
      {
        recorded_response_uuids: given_responses.map { |response|
          response.fetch(:response_uuid)
        }
      }
    }

    let(:target_response) { process_result }

    let(:service_double) {
      object_double(Services::RecordResponses::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(process_payload).and_return(process_result)
      end
    }

    before(:each) do
      allow(Services::RecordResponses::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = record_responses(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the RecordResponses service is called with the correct response data" do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = record_responses(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  protected

  def record_responses(request_payload:)
    make_post_request(
      route:   '/record_responses',
      headers: { 'Content-Type' => 'application/json' },
      body:    request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
