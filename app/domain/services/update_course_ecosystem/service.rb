class Services::UpdateCourseEcosystem::Service
  def process(update_requests:)
    ##
    ## Convert the update attributes to CourseEvents.
    ##

    course_events = responses.map{ |response|
      CourseEvent.new(
        event_uuid:             update_data.fetch(:request_uuid),
        event_type:             CourseEvent.event_type.update_course_ecosystem,
        course_uuid:            update_data.fetch(:course_uuid),
        course_seqnum:          update_data.fetch(:sequence_number),
        event_has_been_bundled: false,
        event_data: update_data.slice(
          :request_uuid,
          :course_uuid,
          :sequence_number,
          :preparation_uuid,
          :updated_at,
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
