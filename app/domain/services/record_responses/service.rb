class Services::RecordResponses::Service #< Services::ApplicationService
  def process(responses:)
    ##
    ## Extract the Response attributes and convert them to CourseEvents.
    ##

    recorded_response_uuids = responses.uniq{|response| response.fetch(:response_uuid)}

    course_events = responses.map{ |response|
      CourseEvent.new(
        uuid:            response.fetch(:response_uuid),
        type:            :record_response,
        course_uuid:     response.fetch(:course_uuid),
        sequence_number: response.fetch(:sequence_number),
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
    ## Prepare some data for the transaction below.
    ##

    ## Sorting ensures that deadlocks will not happen.
    course_uuids       = course_events.map(&:course_uuid).uniq.sort
    course_uuid_values = course_uuids.map{|uuid| "'#{uuid}'"}.join(',')

    ## We want to quickly look up sequence numbers by course.
    seqnums_by_course_uuid = course_events.inject({}) { |result, event|
      result[event.course_uuid] = {} unless result.has_key?(event.course_uuid)
      result[event.course_uuid][event.course_seqnum] = true
      result
    }

    ##
    ## Record the responses and update the associated CourseEventIndicators
    ## (if needed).
    ##

    CourseEvent.transaction(isolation_level: :read_committed) do
      ##
      ## Import the new CourseEvents, ignoring any that might
      ## already be present (idempotency).
      ##

      CourseEvent.import course_events on_duplicate_key_ignore: true;

      ##
      ## Find and lock the associated course states.
      ##

      sql_find_and_lock_course_event_indicators = %Q{
        SELECT * FROM course_event_indicators
        WHERE course_uuid IN ( #{course_uuid_values} )
        ORDER BY course_uuid ASC
        FOR UPDATE
      }.gsub(/\n\s*/, ' ')

      course_event_indicators = CourseEventIndicator.find_by_sql(sql_find_and_lock_course_event_indicators)

      ##
      ## Update and save the course event indicators.
      ##
      ## We only need to update needs_attention for a particular course
      ## if this batch of CourseEvents contains the next unprocessed
      ## sequence number for that course.  Otherwise just leave it alone.
      ##

      indicators_to_update = course_event_indicators.select{ |indicator|
        seqnums_by_course_uuid[indicator.course_uuid].has_key?(1 + indicator.last_course_seqnum)
      }.each{ |indicator|
        indicator.needs_attention = true
        indicator.waiting_since   = Time.now
      }

      CourseEventIndicator.import(
        indicators_to_update,
        on_duplicate_key_update: {
          conflict_target: [:course_uuid],
          columns: CourseEventIndicator.column_names - ['updated_at', 'created_at']
        }
      )
    end

    ##
    ## Return the uuids of the responses that (a) we just saved
    ## and/or (b) were already saved (idempotency).
    ##

    { recorded_response_uuids: recorded_response_uuids }
  end
end
