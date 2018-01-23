class Services::CreateCourse::Service
  def process(course_info:)
    ##
    ## Convert the course attributes to a CourseEvent.
    ##

    course_event = CourseEvent.new(
      event_uuid:         course_info.fetch(:course_uuid),
      event_type:         CourseEvent.event_type.create_course,
      course_uuid:        course_info.fetch(:course_uuid),
      course_seqnum:      0,
      has_been_processed: false,
      data: course_info.slice(
        :course_uuid,
        :sequence_number,
        :ecosystem_uuid,
        :is_real_course,
        :starts_at,
        :ends_at,
        :created_at,
      ),
    )

    ##
    ## Delegate to the CourseEvent recording service, which handles
    ## the details of transaction isolation, locks, etc.
    ##

    recorded_event_uuids = Services::RecordCourseEvents::Service.new.process(course_events: [course_event]);

    return {created_course_uuid: recorded_event_uuids.first}
  end
end
