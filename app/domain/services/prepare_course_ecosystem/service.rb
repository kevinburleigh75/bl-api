class Services::PrepareCourseEcosystem::Service
  def process(preparation_info:)
    ##
    ## Convert the preparation attributes to a CourseEvent.
    ##

    course_event = CourseEvent.new(
      event_uuid:             preparation_info.fetch(:preparation_uuid),
      event_type:             CourseEvent.event_type.update_course_ecosystem,
      course_uuid:            preparation_info.fetch(:course_uuid),
      course_seqnum:          preparation_info.fetch(:sequence_number),
      event_has_been_bundled: false,
      event_data: preparation_info.slice(
        :preparation_uuid,
        :course_uuid,
        :sequence_number,
        :ecosystem_map,
        :exercise_mappings,
        :prepared_at,
      ),
    )

    ##
    ## Delegate to the RecordCourseEvents utility.
    ##

    recorded_event_uuids = CourseEvent.transaction(isolation: :read_committed) do
      Utils::RecordCourseEvents::Util.new.process(course_events: [course_event])
    end

    return {status: 'accepted'}
  end
end
