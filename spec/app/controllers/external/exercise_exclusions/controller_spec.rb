require 'rails_helper'

RSpec.describe External::ExerciseExclusionsController, type: :request do
  context "updating course exclusions" do
    let(:given_exclusions) {
      {
        request_uuid:    SecureRandom.uuid.to_s,
        course_uuid:     SecureRandom.uuid.to_s,
        sequence_number: Kernel.rand(10),
        exclusions:      [
          { exercise_uuid:       SecureRandom.uuid.to_s},
          { exercise_group_uuid: SecureRandom.uuid.to_s},
        ],
        updated_at:      Time.current.iso8601(6),
      }
    }

    let(:request_payload) { given_exclusions }

    let(:process_payload) { {exclusions: given_exclusions} }

    let(:process_result) { target_response }

    let(:target_response) { {status: 'success'} }

    let(:service_double) {
      object_double(Services::UpdateCourseExerciseExclusions::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(process_payload).and_return(process_result)
      end
    }

    before(:each) do
      allow(Services::UpdateCourseExerciseExclusions::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = update_course_exercise_exclusions(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = update_course_exercise_exclusions(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the UpdateCourseExerciseExclusions service is called with the correct exclusion data" do
        response_status, response_body = update_course_exercise_exclusions(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response body is correct" do
        response_status, response_body = update_course_exercise_exclusions(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  context "updating global exclusions" do
    let(:given_exclusions) {
      {
        request_uuid:    SecureRandom.uuid.to_s,
        course_uuid:     SecureRandom.uuid.to_s,
        sequence_number: Kernel.rand(10),
        exclusions:      [
          { exercise_uuid:       SecureRandom.uuid.to_s},
          { exercise_group_uuid: SecureRandom.uuid.to_s},
        ],
        updated_at:      Time.current.iso8601(6),
      }
    }

    let(:request_payload) { given_exclusions }

    let(:process_payload) { {exclusions: given_exclusions} }

    let(:process_result) { target_response }

    let(:target_response) { {status: 'success'} }

    let(:service_double) {
      object_double(Services::UpdateGlobalExerciseExclusions::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(process_payload).and_return(process_result)
      end
    }

    before(:each) do
      allow(Services::UpdateGlobalExerciseExclusions::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = update_global_exercise_exclusions(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = update_global_exercise_exclusions(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the UpdateCourseExerciseExclusions service is called with the correct exclusion data" do
        response_status, response_body = update_global_exercise_exclusions(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response body is correct" do
        response_status, response_body = update_global_exercise_exclusions(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  def update_course_exercise_exclusions(request_payload:)
    make_post_request(
      route:   '/update_course_exercise_exclusions',
      headers: { 'Content-Type' => 'application/json' },
      body:    request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def update_global_exercise_exclusions(request_payload:)
    make_post_request(
      route:   '/update_global_exercise_exclusions',
      headers: { 'Content-Type' => 'application/json' },
      body:    request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
