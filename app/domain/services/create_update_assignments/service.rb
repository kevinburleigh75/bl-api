class Services::CreateUpdateAssignments::Service
  def process(assignments:)
    ##
    ## Convert the assignment info into CourseEvents.
    ##

    course_events = assignments.map{ |assignment|
      CourseEvent.new(
        event_uuid:    assignment.fetch(:request_uuid),
        event_type:    CourseEvent.event_type.create_update_assignment,
        course_uuid:   assignment.fetch(:course_uuid),
        course_seqnum: assignment.fetch(:sequence_number),
        event_data: assignment.slice(
          :request_uuid,
          :course_uuid,
          :sequence_number,
          :assignment_uuid,
          :is_deleted,
          :ecosystem_uuid,
          :student_uuid,
          :assignment_type,
          :exclusion_info,
          :assigned_book_container_uuids,
          :goal_num_tutor_assigned_spes,
          :spes_are_assigned,
          :goal_num_tutor_assigned_pes,
          :pes_are_assigned,
          :assigned_exercises,
          :created_at,
          :updated_at,
        )
      )
    }

    ##
    ## Delegate to the RecordCourseEvents utility.
    ##

    CourseEvent.transaction(isolation: :read_committed) do
      Utils::RecordCourseEvents::Util.new.process(course_events: course_events)
    end

    ##
    ## Return an array of hashes describing the created/updated assignments.
    ##

    updated_assignments = assignments.map{ |assignment|
      {
        request_uuid:    assignment.fetch(:request_uuid),
        assignment_uuid: assignment.fetch(:assignment_uuid),
      }
    }

    return {updated_assignments: updated_assignments}
  end
end
