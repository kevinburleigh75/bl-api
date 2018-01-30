class Services::RecordResponses::Service
  def process(responses:)
    ##
    ## Convert the response attributes to CourseEvents.
    ##

    course_events = responses.map{ |response|
      CourseEvent.new(
        event_uuid:             response.fetch(:response_uuid),
        event_type:             CourseEvent.event_type.record_response,
        course_uuid:            response.fetch(:course_uuid),
        course_seqnum:          response.fetch(:sequence_number),
        event_has_been_bundled: false,
        event_data: response.slice(
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
    ## Delegate to the RecordCourseEvents utility.
    ##

    recorded_event_uuids = CourseEvent.transaction(isolation: :read_committed) do
      Utils::RecordCourseEvents::Util.new.process(course_events: course_events)
    end

    return {recorded_response_uuids: recorded_event_uuids}
  end
end
