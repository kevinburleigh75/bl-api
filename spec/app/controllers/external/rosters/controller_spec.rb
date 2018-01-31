require 'rails_helper'

RSpec.describe External::RostersController, type: :request do
  let(:roster_infos) {
    [
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
    ]
  }

  let(:request_payload) { {rosters: roster_infos} }

  let(:process_payload) { request_payload }
  let(:process_result)  {
    {
      updated_rosters: roster_infos.map{ |roster|
        {
          request_uuid:        roster.fetch(:request_uuid),
          updated_course_uuid: roster.fetch(:course_uuid),
        }
      }
    }
  }

  let(:target_response) { process_result }

  let(:service_double) {
    object_double(Services::UpdateRosters::Service.new).tap do |dbl|
      allow(dbl).to receive(:process).with(process_payload).and_return(process_result)
    end
  }

  before(:each) do
    allow(Services::UpdateRosters::Service).to receive(:new).and_return(service_double)
  end

  context "when a valid request is made" do
    it "the request and response payloads are validated against their schemas" do
      expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
      response_status, response_body = update_rosters(request_payload: request_payload)
    end

    it "the response has status 200 (success)" do
      response_status, response_body = update_rosters(request_payload: request_payload)
      expect(response_status).to eq(200)
    end

    it "the UpdateRosters service is called with the correct roster data" do
      response_status, response_body = update_rosters(request_payload: request_payload)
      expect(service_double).to have_received(:process)
    end

    it "the response contains the target_response" do
      response_status, response_body = update_rosters(request_payload: request_payload)
      expect(response_body).to eq(target_response.deep_stringify_keys)
    end
  end

  protected

  def update_rosters(request_payload:)
    make_post_request(
      route:   '/update_rosters',
      headers: { 'Content-Type' => 'application/json' },
      body:    request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
