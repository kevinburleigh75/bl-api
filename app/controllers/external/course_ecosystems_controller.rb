class External::CourseEcosystemsController < JsonApiController

  def prepare
    with_json_apis(input_schema:  _prepare_request_payload_schema,
                   output_schema: _prepare_response_payload_schema) do |request_payload|
      Services::PrepareCourseEcosystem::Service.new.process(preparation_info: request_payload)
    end
  end

  def update
    respond_with_json_apis_and_service(
      input_schema:  _update_request_payload_schema,
      output_schema: _update_response_payload_schema,
      service:       Services::UpdateCourseEcosystem::Service.new,
    )
  end

  protected

  def _prepare_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'preparation_uuid':    {'$ref': '#standard_definitions/uuid'},
        'course_uuid':         {'$ref': '#standard_definitions/uuid'},
        'sequence_number':     {'$ref': '#standard_definitions/non_negative_integer'},
        'next_ecosystem_uuid': {'$ref': '#standard_definitions/uuid'},
        'ecosystem_map': {
          'type': 'object',
          'properties': {
            'from_ecosystem_uuid': {'$ref': '#standard_definitions/uuid'},
            'to_ecosystem_uuid':   {'$ref': '#standard_definitions/uuid'},
            'book_container_mappings': {
              'type': 'array',
              'items': {'$ref': '#definitions/book_container_mapping'},
              'minItems': 0,
              'maxItems': 500
            },
            'exercise_mappings': {
              'type': 'array',
              'items': {'$ref': '#definitions/exercise_mapping'},
              'minItems': 0,
              'maxItems': 10000
            }
          },
          'required': [
            'from_ecosystem_uuid',
            'to_ecosystem_uuid',
            'book_container_mappings',
            'exercise_mappings'
          ],
          'additionalProperties': false
        },
        'prepared_at': {'$ref': '#/standard_definitions/datetime'}
      },
      'required': [
        'preparation_uuid',
        'course_uuid',
        'sequence_number',
        'next_ecosystem_uuid',
        'ecosystem_map',
        'prepared_at'
      ],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'book_container_mapping': {
          'type': 'object',
          'properties': {
            'from_book_container_uuid': {'$ref': '#standard_definitions/uuid'},
            'to_book_container_uuid':   {'$ref': '#standard_definitions/uuid'},
          },
          'required': ['from_book_container_uuid', 'to_book_container_uuid'],
          'additionalProperties': false
        },
        'exercise_mapping': {
          'type': 'object',
          'properties': {
            'from_exercise_uuid':     {'$ref': '#standard_definitions/uuid'},
            'to_book_container_uuid': {'$ref': '#standard_definitions/uuid'},
          },
          'required': ['from_exercise_uuid', 'to_book_container_uuid'],
          'additionalProperties': false
        }
      }
    }
  end

  def _prepare_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'status': {
          'type': 'string',
          'enum': ['accepted'],
        }
      },
      'required': ['status'],
      'additionalProperties': false
    }
  end

  def _update_request_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'update_requests': {
          'type': 'array',
          'items': {'$ref': '#definitions/update_request'},
          'minItems': 0,
          'maxItems': 1000,
        }
      },
      'required': ['update_requests'],
      'additionalProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'update_request': {
          'type': 'object',
          'properties': {
            'request_uuid':     {'$ref': '#standard_definitions/uuid'},
            'course_uuid':      {'$ref': '#standard_definitions/uuid'},
            'sequence_number':  {'$ref': '#standard_definitions/non_negative_integer'},
            'preparation_uuid': {'$ref': '#standard_definitions/uuid'},
            'updated_at':       {'$ref': '#/standard_definitions/datetime'}
          },
          'required': [
            'request_uuid',
            'course_uuid',
            'sequence_number',
            'preparation_uuid',
            'updated_at'
          ],
          'additionalProperties': false
        }
      }
    }
  end

  def _update_response_payload_schema
    {
      '$schema': JSON_SCHEMA,

      'type': 'object',
      'properties': {
        'update_responses': {
          'type': 'array',
          'items': {'$ref': '#definitions/update_response'},
          'minItems': 0,
          'maxItems': 1000,
        }
      },
      'required': ['update_responses'],
      'additionProperties': false,
      'standard_definitions': _standard_definitions,
      'definitions': {
        'update_response': {
          'type': 'object',
          'properties': {
            'request_uuid': {'$ref': '#standard_definitions/uuid'},
            'update_status': {
              'type': 'string',
              'enum': [
                'preparation_unknown',
                'preparation_obsolete',
                'updated_but_unready',
                'updated_and_ready'
              ]
            }
          },
          'required': ['request_uuid', 'update_status'],
          'additionalProperties': false
        }
      }
    }
  end

end
