require 'rails_helper'

RSpec.describe External::CluesController, type: :request do
  context "fetching student CLUEs" do
    let(:service_double) do
      object_double(Services::FetchStudentClues::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(process_payload).and_return(process_result)
      end
    end

    let(:given_clue_requests) do
      [
        {
          request_uuid:        SecureRandom.uuid.to_s,
          student_uuid:        SecureRandom.uuid.to_s,
          book_container_uuid: SecureRandom.uuid.to_s,
          algorithm_name:      'alg_name_1',
        },
        {
          request_uuid:        SecureRandom.uuid.to_s,
          student_uuid:        SecureRandom.uuid.to_s,
          book_container_uuid: SecureRandom.uuid.to_s,
          algorithm_name:      'alg_name_2',
        },
      ]
    end

    let(:request_payload) { { student_clue_requests: given_clue_requests } }

    let(:process_payload) { request_payload }

    let(:process_result) do
      {
        student_clue_responses:
        [
          {
            request_uuid:     given_clue_requests[0][:request_uuid],
            clue_data: {
              minimum:        0.7,
              most_likely:    0.8,
              maximum:        0.9,
              is_real:        true,
              ecosystem_uuid: SecureRandom.uuid.to_s,
            },
            clue_status: 'clue_ready',
          },
          {
            request_uuid: given_clue_requests[1][:request_uuid],
            clue_data: {
              minimum:     0,
              most_likely: 0.5,
              maximum:     1,
              is_real:     false
            },
            clue_status: 'student_unknown',
          }
        ]
      }
    end

    let(:target_response) { process_result }

    before(:each) do
      allow(Services::FetchStudentClues::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_student_clues(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_student_clues(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the FetchStudentClues service is called with the correct course data" do
        response_status, response_body = fetch_student_clues(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the correct information" do
        response_status, response_body = fetch_student_clues(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  context "fetch teacher CLUEs" do
    let(:given_clue_requests) do
      [
        {
          request_uuid:          SecureRandom.uuid.to_s,
          course_container_uuid: SecureRandom.uuid.to_s,
          book_container_uuid:   SecureRandom.uuid.to_s,
          algorithm_name:        'alg_name_1',
        },
        {
          request_uuid:          SecureRandom.uuid.to_s,
          course_container_uuid: SecureRandom.uuid.to_s,
          book_container_uuid:   SecureRandom.uuid.to_s,
          algorithm_name:        'alg_name_2',
        }
      ]
    end

    let(:request_payload) { { teacher_clue_requests: given_clue_requests } }

    let(:process_payload) { request_payload }

    let(:process_result) do
      {
        teacher_clue_responses: [
          {
            request_uuid: given_clue_requests[0][:request_uuid],
            clue_data: {
              minimum:        0.7,
              most_likely:    0.8,
              maximum:        0.9,
              is_real:        true,
              ecosystem_uuid: SecureRandom.uuid.to_s,
            },
            clue_status: 'clue_ready'
          },
          {
            request_uuid: given_clue_requests[1][:request_uuid],
            clue_data: {
              minimum:     0,
              most_likely: 0.5,
              maximum:     1,
              is_real:     false,
            },
            clue_status: 'course_container_unknown'
          }
        ]
      }
    end

    let(:target_response) { process_result }

    let(:service_double) do
      object_double(Services::FetchTeacherClues::Service.new).tap do |dbl|
        allow(dbl).to receive(:process).with(process_payload).and_return(process_result)
      end
    end

    before(:each) do
      allow(Services::FetchTeacherClues::Service).to receive(:new).and_return(service_double)
    end

    context "when a valid request is made" do
      it "the request and response payloads are validated against their schemas" do
        expect_any_instance_of(described_class).to receive(:with_json_apis).and_call_original
        response_status, response_body = fetch_teacher_clues(request_payload: request_payload)
      end

      it "the response has status 200 (success)" do
        response_status, response_body = fetch_teacher_clues(request_payload: request_payload)
        expect(response_status).to eq(200)
      end

      it "the FetchStudentClues service is called with the correct course data" do
        response_status, response_body = fetch_teacher_clues(request_payload: request_payload)
        expect(service_double).to have_received(:process)
      end

      it "the response contains the correct information" do
        response_status, response_body = fetch_teacher_clues(request_payload: request_payload)
        expect(response_body).to eq(target_response.deep_stringify_keys)
      end
    end
  end

  protected

  def fetch_student_clues(request_payload:)
    make_post_request(
      route:   '/fetch_student_clues',
      headers: { 'Content-Type' => 'application/json' },
      body:    request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end

  def fetch_teacher_clues(request_payload:)
    make_post_request(
      route:   '/fetch_teacher_clues',
      headers: { 'Content-Type' => 'application/json' },
      body:    request_payload.to_json
    )
    response_status  = response.status
    response_payload = JSON.parse(response.body)

    [response_status, response_payload]
  end
end
