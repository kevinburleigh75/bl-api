class Services::CreateCourse::Service
  def process(course_info:)
    ##
    ## Convert the course attributes to a CourseEvent.
    ##

    course_event = CourseEvent.new(
      event_uuid:             course_info.fetch(:course_uuid),
      event_type:             CourseEvent.event_type.create_course,
      event_has_been_bundled: false,
      course_uuid:            course_info.fetch(:course_uuid),
      course_seqnum:          0,
      event_data: course_info.slice(
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
    ## Delegate to the CourseEvent recording utility.
    ##

    recorded_event_uuids = CourseEvent.transaction(isolation: :read_committed) do
      Utils::RecordCourseEvents::Util.new.process(course_events: [course_event])
    end

    return {created_course_uuid: recorded_event_uuids.first}
  end
end
