class External::CoursesController < JsonApiController

  def create
    with_json_apis(input_schema:  _create_request_payload_schema,
                   output_schema: _create_response_payload_schema) do |request_payload|
      Services::CreateCourse::Service.new.process(course_info: request_payload)
    end
  end

  def update_active_dates
    with_json_apis(input_schema:  _update_active_dates_request_payload_schema,
                   output_schema: _update_active_dates_response_payload_schema) do |request_payload|
      Services::UpdateCourseActiveDates::Service.new.process(course_info: request_payload)
    end
  end

  protected

  def _create_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'course_uuid':    {'$ref': '#/standard_definitions/uuid'},
        'ecosystem_uuid': {'$ref': '#/standard_definitions/uuid'},
        'is_real_course': {'type': 'boolean'},
        'starts_at':      {'$ref': '#/standard_definitions/datetime'},
        'ends_at':        {'$ref': '#/standard_definitions/datetime'},
        'created_at':     {'$ref': '#/standard_definitions/datetime'}
      },
      'required': [
        'course_uuid',
        'ecosystem_uuid',
        'is_real_course',
        'starts_at',
        'ends_at',
        'created_at'
      ],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _create_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'created_course_uuid': {'$ref': '#/standard_definitions/uuid'},
      },
      'required': ['created_course_uuid'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _update_active_dates_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'request_uuid':    {'$ref': '#standard_definitions/uuid'},
        'course_uuid':     {'$ref': '#/standard_definitions/uuid'},
        'sequence_number': {'$ref': '#/standard_definitions/non_negative_integer'},
        'starts_at':       {'$ref': '#/standard_definitions/datetime'},
        'ends_at':         {'$ref': '#/standard_definitions/datetime'},
        'updated_at':      {'$ref': '#/standard_definitions/datetime'}
      },
      'required': [
        'request_uuid',
        'course_uuid',
        'sequence_number',
        'starts_at',
        'ends_at',
        'updated_at'
      ],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end

  def _update_active_dates_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'updated_course_uuid': {'$ref': '#/standard_definitions/uuid'},
      },
      'required': ['updated_course_uuid'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions
    }
  end
end
