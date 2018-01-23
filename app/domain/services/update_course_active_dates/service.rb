class Services::UpdateCourseActiveDates::Service
  def process(request_uuid:, course_uuid:, sequence_number:, starts_at:, ends_at:, updated_at:)
    return {updated_course_uuid: 'f7b1bef7-a82d-4555-b037-dcf5944e1111'}
  end
end
