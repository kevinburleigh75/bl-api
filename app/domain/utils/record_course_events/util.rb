class Utils::RecordCourseEvents::Util
  def process(course_events:)
    ## This avoids problems in the SQL below when
    ## there are no course events.
    return [] if course_events.none?

    ##
    ## Prepare some handy values.
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
    ## Import the new CourseEvents, ignoring any that might
    ## already be present (idempotency).
    ##

    CourseEvent.import course_events, on_duplicate_key_ignore: true

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
    ## If there are previously-unseen courses, create indicators for them.
    ##

    indicator_course_uuids = course_event_indicators.map(&:course_uuid).sort

    if indicator_course_uuids != course_uuids
      new_course_event_indicators = (course_uuids - indicator_course_uuids).map{ |course_uuid|
        CourseEventIndicator.new(
          course_uuid:                course_uuid,
          course_last_bundled_seqnum: -1,
          course_needs_attention:     false,
          course_waiting_since:       Time.current,
        )
      }

      CourseEventIndicator.import new_course_event_indicators, on_duplicate_key_ignore: true
      course_event_indicators.concat(new_course_event_indicators)
    end

    ##
    ## Update and save the course event indicators.
    ##
    ## We only need to update needs_attention for a particular course
    ## if this batch of CourseEvents contains the next unprocessed
    ## sequence number for that course.  Otherwise just leave it alone.
    ##

    indicators_to_update = course_event_indicators.select{ |indicator|
      !indicator.course_needs_attention &&
      seqnums_by_course_uuid[indicator.course_uuid].has_key?(1 + indicator.course_last_bundled_seqnum)
    }.each{ |indicator|
      indicator.course_needs_attention = true
      indicator.course_waiting_since   = Time.now
    }

    CourseEventIndicator.import(
      indicators_to_update,
      on_duplicate_key_update: {
        conflict_target: [:course_uuid],
        columns: CourseEventIndicator.column_names - ['updated_at', 'created_at']
      }
    )

    ##
    ## Return the uuids of the CourseEvents that either:
    ##   (a) we just saved, and/or
    ##   (b) were already saved (idempotency).
    ##

    recorded_course_event_uuids = course_events.map{|event| event.event_uuid}.uniq

    return recorded_course_event_uuids
  end
end
