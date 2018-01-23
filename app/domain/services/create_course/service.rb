class Services::CreateCourse::Service
  def process(course_uuid:, ecosystem_uuid:, is_real_course:, starts_at:, ends_at:, created_at:)
    return {created_course_uuid: "10"}
  end
end
