require 'rails_helper'

RSpec.describe External::AssignmentsController, type: :request do
  context "creating and updating assignments" do

    let(:assignment_infos) do
      [
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
      ]
    end

    let(:request_payload) { {assignments: assignment_infos} }

    let(:process_payload) { request_payload }
    let(:process_result)  {
      {
        updated_assignments: assignment_infos.map{ |info|
          {
            request_uuid:            info.fetch(:request_uuid),
            updated_assignment_uuid: info.fetch(:assignment_uuid),
          }
        }
      }
    }

    let(:target_response) { process_result }

    let(:service_double) do
      object_double(Services::CreateUpdateAssignments::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(process_payload).and_return(process_result)
      end
    end

    before(:each) do
      allow(Services::CreateUpdateAssignments::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = create_update_assignments(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = create_update_assignments(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the CreateUpdateAssignments service is called with the correct course data" do
        response_status, response_body = create_update_assignments(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the target_response" do
        response_status, response_body = create_update_assignments(request_payload: request_payload)
        expect(response_body.deep_symbolize_keys).to eq(target_response)
      end
    end
  end

  protected

  def create_update_assignments(request_payload:)
    make_post_request(
      route:   '/create_update_assignments',
      headers: { 'Content-Type' => 'application/json' },
      body:    request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
