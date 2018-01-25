class Services::UpdateCourseActiveDates::Service
  def process(course_info:)
    ##
    ## Convert the course attributes to a CourseEvent.
    ##

    course_event = CourseEvent.new(
      event_uuid:             course_info.fetch(:request_uuid),
      event_type:             CourseEvent.event_type.update_course_active_dates,
      course_uuid:            course_info.fetch(:course_uuid),
      course_seqnum:          course_info.fetch(:sequence_number),
      event_has_been_bundled: false,
      event_data: course_info.slice(
        :request_uuid,
        :course_uuid,
        :sequence_number,
        :starts_at,
        :ends_at,
        :updated_at,
      ),
    )

    ##
    ## Delegate to the CourseEvent recording service, which handles
    ## the details of transaction isolation, locks, etc.
    ##

    recorded_event_uuids = Services::RecordCourseEvents::Service.new.process(course_events: [course_event]);

    return {updated_course_uuid: recorded_event_uuids.first}
  end
end
