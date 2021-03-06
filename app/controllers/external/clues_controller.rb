class External::CluesController < JsonApiController

  def fetch_student
    respond_with_json_apis_and_service(
      input_schema:  _fetch_student_request_payload_schema,
      output_schema: _fetch_student_response_payload_schema,
      service:       Services::FetchStudentClues::Service.new,
    )
  end

  def fetch_teacher
    respond_with_json_apis_and_service(
      input_schema:  _fetch_teacher_request_payload_schema,
      output_schema: _fetch_teacher_response_payload_schema,
      service:       Services::FetchTeacherClues::Service.new,
    )
  end

  def _fetch_student_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'student_clue_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/student_clue_request'},
          'minItems': 0,
          'maxItems': 50,
        },
      },
      'required': ['student_clue_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'student_clue_request': {
          'type': 'object',
          'properties': {
            'request_uuid':        {'$ref': '#standard_definitions/uuid'},
            'student_uuid':        {'$ref': '#standard_definitions/uuid'},  ## Course-specific Student uuid
            'book_container_uuid': {'$ref': '#standard_definitions/uuid'},  ## Ecosystem-specific uuid (not CNX uuid)
            'algorithm_name':      {'type': 'string'}
          },
          'required': ['request_uuid', 'student_uuid', 'book_container_uuid', 'algorithm_name'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _fetch_student_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'student_clue_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/student_clue_response'},
          'minItems': 0,
          'maxItems': 50,
        },
      },
      'required': ['student_clue_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'student_clue_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'clue_data':    {'$ref': '#standard_definitions/clue_data'},
            'clue_status': {
              'type': 'string',
              'enum': ['student_unknown', 'book_container_unknown', 'clue_unready', 'clue_ready'],
            },
          },
          'required': ['request_uuid', 'clue_data', 'clue_status'],
          'additionalProperties': false,
        },
      },
    }
  end

  def _fetch_teacher_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'teacher_clue_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/teacher_clue_request'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['teacher_clue_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'teacher_clue_request': {
          'type': 'object',
          'properties': {
            'request_uuid':          {'$ref': '#standard_definitions/uuid'},
            'course_container_uuid': {'$ref': '#standard_definitions/uuid'},  ## Course-specific period, etc., container uuid
            'book_container_uuid':   {'$ref': '#standard_definitions/uuid'},  ## Ecosystem-specific uuid (not CNX uuid)
            'algorithm_name':        {'type': 'string'}
          },
          'required': [
            'request_uuid',
            'course_container_uuid',
            'book_container_uuid',
            'algorithm_name'
          ],
          'additionalProperties': false,
        },
      },
    }
  end

  def _fetch_teacher_response_payload_schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',

      'type': 'object',
      'properties': {
        'teacher_clue_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/teacher_clue_response'},
          'minItems': 0,
          'maxItems': 1000,
        },
      },
      'required': ['teacher_clue_responses'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'teacher_clue_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'clue_data':    {'$ref': '#standard_definitions/clue_data'},
            'clue_status': {
              'type': 'string',
              'enum': [
                'course_container_unknown', 'book_container_unknown', 'clue_unready', 'clue_ready'
              ],
            },
          },
          'required': ['request_uuid', 'clue_data', 'clue_status'],
          'additionalProperties': false,
        },
      },
    }
  end

end
