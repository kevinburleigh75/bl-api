class Services::UpdateRosters::Service
  def process(rosters:)
    ##
    ## Convert the given roster attributes into CourseEvents.
    ##

    course_events = rosters.map{ |roster_data|
      CourseEvent.new(
        event_uuid:             roster_data.fetch(:request_uuid),
        event_type:             CourseEvent.event_type.update_roster,
        course_uuid:            roster_data.fetch(:course_uuid),
        course_seqnum:          roster_data.fetch(:sequence_number),
        event_has_been_bundled: false,
        event_data: roster_data.slice(
          :request_uuid,
          :course_uuid,
          :sequence_number,
          :course_containers,
          :students,
        ),
      )
    }

    ##
    ## Delegate to the RecordCourseEvents utility.
    ##

    recorded_event_uuids = CourseEvent.transaction(isolation: :read_committed) do
      Utils::RecordCourseEvents::Util.new.process(course_events: course_events)
    end

    updated_rosters = rosters.map{ |roster_data|
      {
        request_uuid:        roster_data.fetch(:request_uuid),
        updated_course_uuid: roster_data.fetch(:course_uuid),
      }
    }
    return {updated_rosters: updated_rosters}
  end
end
