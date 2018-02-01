class Services::UpdateGlobalExerciseExclusions::Service
  def process(exclusions:)
    ##
    ## Convert the exclusion attributes to CourseEvents.
    ##

    course_event = CourseEvent.new(
      event_uuid:             exclusions.fetch(:request_uuid),
      event_type:             CourseEvent.event_type.update_global_exercise_exclusions,
      course_uuid:            exclusions.fetch(:course_uuid),
      course_seqnum:          exclusions.fetch(:sequence_number),
      event_has_been_bundled: false,
      event_data: exclusions.slice(
        :request_uuid,
        :exclusions,
      ),
    )

    ##
    ## Delegate to the RecordCourseEvents utility.
    ##

    recorded_event_uuids = CourseEvent.transaction(isolation: :read_committed) do
      Utils::RecordCourseEvents::Util.new.process(course_events: [course_event])
    end

    return {status: 'success'}
  end
end
