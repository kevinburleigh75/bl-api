class Services::RecordResponses::Service
  def process(responses:)
    ##
    ## Convert the response attributes to CourseEvents.
    ##

    course_events = responses.map{ |response|
      CourseEvent.new(
        event_uuid:         response.fetch(:response_uuid),
        event_type:         CourseEvent.event_type.record_response,
        course_uuid:        response.fetch(:course_uuid),
        course_seqnum:      response.fetch(:sequence_number),
        has_been_processed: false,
        data: response.slice(
          :response_uuid,
          :course_uuid,
          :sequence_number,
          :ecosystem_uuid,
          :trial_uuid,
          :student_uuid,
          :exercise_uuid,
          :is_correct,
          :is_real_response,
          :responded_at,
        ),
      )
    }

    ##
    ## Delegate to the CourseEvent recording service, which handles
    ## the details of transaction isolation, locks, etc.
    ##

    recorded_event_uuids = Services::RecordCourseEvents::Service.new.process(course_events: course_events);

    return {recorded_response_uuids: recorded_event_uuids}
  end
end
