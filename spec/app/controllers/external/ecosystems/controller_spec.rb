require 'rails_helper'

RSpec.describe External::EcosystemsController, type: :request do
  context "ecosystem creation" do
    let(:request_payload) {
      {
        ecosystem_uuid: SecureRandom.uuid.to_s,
        book:           {},
        exercises:      [],
        imported_at:    Time.current.iso8601(6),
      }
    }

    let(:process_payload) { {ecosystem_info: request_payload} }
    let(:process_result)  { {created_ecosystem_uuid: request_payload[:ecosystem_uuid]} }

    let(:target_response) { process_result }

    let(:service_double) do
      object_double(Services::CreateEcosystem::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(process_payload).and_return(process_result)
      end
    end

    before(:each) do
      allow(Services::CreateEcosystem::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = create_ecosystem(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = create_ecosystem(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the CreateEcosystem service is called with the correct ecosystem data" do
        response_status, response_body = create_ecosystem(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the created ecosystem uuid" do
        response_status, response_body = create_ecosystem(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  protected

  def create_ecosystem(request_payload:)
    make_post_request(
      route:   '/create_ecosystem',
      headers: { 'Content-Type' => 'application/json' },
      body:    request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

end
