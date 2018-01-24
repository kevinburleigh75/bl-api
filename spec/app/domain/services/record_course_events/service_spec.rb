require 'rails_helper'

RSpec.describe Services::RecordCourseEvents::Service do
  let(:service) { described_class.new }

  let(:action)  { service.process(course_events: given_course_events) }

  context "no CourseEvents are given" do
    let(:given_course_events) { [] }

    it "no CourseEvents are created" do
      expect{action}.to_not change{CourseEvent.count}
    end

    it "no CourseEventIndicators are created" do
      expect{action}.to_not change{CourseEventIndicator.count}
    end

    it "no CourseEventIndicators are changed" do
      action_time = Time.current
      action
      expect(CourseEventIndicator.where("updated_at >= ?", action_time)).to be_empty
    end

    it "an empty uuid array is returned" do
      expect(action).to be_empty
    end
  end

  context "when CourseEvents are given" do
    let(:course_uuids) { 6.times.map{ SecureRandom.uuid.to_s } }

    let!(:existing_course_event_indicators) {
      [
        FactoryBot.create(:course_event_indicator, course_uuid: course_uuids[2], needs_attention: true,  last_course_seqnum: 2, waiting_since: Time.current),
        FactoryBot.create(:course_event_indicator, course_uuid: course_uuids[3], needs_attention: true,  last_course_seqnum: 2, waiting_since: Time.current),
        FactoryBot.create(:course_event_indicator, course_uuid: course_uuids[4], needs_attention: false, last_course_seqnum: 2, waiting_since: Time.current),
        FactoryBot.create(:course_event_indicator, course_uuid: course_uuids[5], needs_attention: false, last_course_seqnum: 2, waiting_since: Time.current),
      ]
    }

    let!(:existing_course_events) {
      [
        FactoryBot.create(:course_event, course_uuid: course_uuids[2], course_seqnum: 0),
        FactoryBot.create(:course_event, course_uuid: course_uuids[2], course_seqnum: 1),
        FactoryBot.create(:course_event, course_uuid: course_uuids[2], course_seqnum: 2),

        FactoryBot.create(:course_event, course_uuid: course_uuids[3], course_seqnum: 0),
        FactoryBot.create(:course_event, course_uuid: course_uuids[3], course_seqnum: 1),
        FactoryBot.create(:course_event, course_uuid: course_uuids[3], course_seqnum: 2),

        FactoryBot.create(:course_event, course_uuid: course_uuids[4], course_seqnum: 0),
        FactoryBot.create(:course_event, course_uuid: course_uuids[4], course_seqnum: 1),
        FactoryBot.create(:course_event, course_uuid: course_uuids[4], course_seqnum: 2),

        FactoryBot.create(:course_event, course_uuid: course_uuids[5], course_seqnum: 0),
        FactoryBot.create(:course_event, course_uuid: course_uuids[5], course_seqnum: 1),
        FactoryBot.create(:course_event, course_uuid: course_uuids[5], course_seqnum: 2),
      ]
    }

    let(:given_course_events) {
      [
        FactoryBot.build(:course_event, course_uuid: course_uuids[0], course_seqnum: 0),
        FactoryBot.build(:course_event, course_uuid: course_uuids[0], course_seqnum: 1),
        FactoryBot.build(:course_event, course_uuid: course_uuids[0], course_seqnum: 2),

        FactoryBot.build(:course_event, course_uuid: course_uuids[1], course_seqnum: 1),
        FactoryBot.build(:course_event, course_uuid: course_uuids[1], course_seqnum: 2),

        FactoryBot.build(:course_event, course_uuid: course_uuids[2], course_seqnum: 2),
        FactoryBot.build(:course_event, course_uuid: course_uuids[2], course_seqnum: 3),
        FactoryBot.build(:course_event, course_uuid: course_uuids[2], course_seqnum: 4),

        FactoryBot.build(:course_event, course_uuid: course_uuids[3], course_seqnum: 2),
        FactoryBot.build(:course_event, course_uuid: course_uuids[3], course_seqnum: 4),
        FactoryBot.build(:course_event, course_uuid: course_uuids[3], course_seqnum: 5),

        FactoryBot.build(:course_event, course_uuid: course_uuids[4], course_seqnum: 2),
        FactoryBot.build(:course_event, course_uuid: course_uuids[4], course_seqnum: 3),
        FactoryBot.build(:course_event, course_uuid: course_uuids[4], course_seqnum: 4),

        FactoryBot.build(:course_event, course_uuid: course_uuids[5], course_seqnum: 2),
        FactoryBot.build(:course_event, course_uuid: course_uuids[5], course_seqnum: 4),
        FactoryBot.build(:course_event, course_uuid: course_uuids[5], course_seqnum: 5),
      ]
    }

    let(:previously_unseen_course_events) { given_course_events.values_at(0,1,2, 3,4, 6,7, 9,10, 12,13, 15,16) }

    it "CourseEvents are created for only previously-unseen events" do
      action_time = Time.current

      action

      target_event_uuids        = previously_unseen_course_events.map(&:event_uuid)
      newly_created_event_uuids = CourseEvent.where("created_at > ?", action_time)
                                             .map(&:event_uuid)
      expect(newly_created_event_uuids).to match_array(target_event_uuids)
    end

    it "previously-seen CourseEvents are left unchanged" do
      action_time = Time.current

      action

      target_event_uuids = CourseEvent.where(event_uuid: existing_course_events.map(&:event_uuid))
                                      .where("updated_at > ?", action_time)
                                      .map(&:event_uuid)
      expect(target_event_uuids).to be_empty
    end

    it "missing CourseEventIndicators are created" do
      action_time = Time.current

      action

      target_course_uuids = course_uuids.values_at(0,1)
      newly_created_indicator_course_uuids = CourseEventIndicator.where("created_at > ?", action_time)
                                                                 .map(&:course_uuid)
      expect(newly_created_indicator_course_uuids).to match_array(target_course_uuids)
    end

    it "missing CourseEventIndicators for courses that now need attention have correct parameters" do
      action_time = Time.current

      action

      target_course_uuids = course_uuids.values_at(0)
      new_indicators = CourseEventIndicator.where(course_uuid: target_course_uuids)
      expect(new_indicators).to all(have_attributes(needs_attention:    true))
      expect(new_indicators).to all(have_attributes(last_course_seqnum: -1))
      new_indicators.each do |indicator|
        expect(indicator.waiting_since).to be > action_time
      end
    end

    it "missing CourseEventIndicators for courses that do not need attention have correct parameters" do
      action_time = Time.current

      action

      target_course_uuids = course_uuids.values_at(1)
      new_indicators = CourseEventIndicator.where(course_uuid: target_course_uuids)
      expect(new_indicators).to all(have_attributes(needs_attention:    false))
      expect(new_indicators).to all(have_attributes(last_course_seqnum: -1))
    end

    it "CourseEventIndicators for courses that did not need attention and received in-sequence events are updated" do
      action_time = Time.current

      action

      target_course_uuids = course_uuids.values_at(0,4)
      updated_indicators  = CourseEventIndicator.where("updated_at > ?", action_time)
                                                .where(course_uuid: target_course_uuids)
      expect(updated_indicators.count).to eq(target_course_uuids.count)
      expect(updated_indicators).to all(have_attributes(needs_attention: true))
      updated_indicators.each do |indicator|
        expect(indicator.waiting_since).to be > action_time
      end
    end

    it "CourseEventIndicators for courses that already needed attention are not updated" do
      action_time = Time.current

      action

      target_course_uuids = course_uuids.values_at(2,3)
      updated_indicators  = CourseEventIndicator.where("updated_at > ?", action_time)
                                                .where(course_uuid: target_course_uuids)
      expect(updated_indicators.count).to eq(0)
    end

    it "CourseEventIndicators for courses that did not need attention and received out-of-sequence events are not updated" do
      action_time = Time.current

      action

      target_course_uuids = course_uuids.values_at(5)
      updated_indicators  = CourseEventIndicator.where("updated_at > ?", action_time)
                                                .where(course_uuid: target_course_uuids)
      expect(updated_indicators.count).to eq(0)
    end
  end
end
