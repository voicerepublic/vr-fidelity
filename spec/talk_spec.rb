# encoding: UTF-8
require 'spec_helper'

# describe Talk do
#
#   before do
#     Timecop.freeze(Time.local(2036))
#   end
#   after do
#     Timecop.return
#   end
#
#   describe 'user uploads a talk' do
#     describe 'with user upload' do
#       it 'allows only a time of the past' do
#         expect {
#           FactoryGirl.create :talk,
#             starts_at_date: Time.now.strftime('2037-01-01'),
#             user_override_uuid: '038ee6b8-0557-4172-8ad6-2548dccd4793'
#         }.to raise_error(ActiveRecord::RecordInvalid)
#
#         talk = FactoryGirl.build :talk,
#           starts_at_date: Time.now.strftime('2037-01-01'),
#           user_override_uuid: '038ee6b8-0557-4172-8ad6-2548dccd4793'
#
#         talk.valid?
#         talk.errors[:starts_at_date].should include("needs to be in the past")
#         talk.errors[:starts_at_time].should include("needs to be in the past")
#       end
#
#       it 'saves into state "postlive"' do
#         talk = FactoryGirl.build :talk
#         # do not test override feature
#         allow(talk).to receive(:user_override!).and_return(true)
#         talk.state.should_not == :postlive
#         talk.user_override_uuid = '038ee6b8-0557-4172-8ad6-2548dccd4793'
#         talk.save
#         talk.state.should == :postlive
#       end
#     end
#
#     describe 'guard: with no user upload' do
#       it 'also allows a time of the future' do
#         expect {
#           FactoryGirl.create :talk,
#           starts_at_date: Time.now.strftime('2037-01-01')
#         }.to change{Talk.count}.from(0).to(1)
#       end
#       it 'saves into other state than "postlive"' do
#         talk = FactoryGirl.create :talk
#         talk.state.should_not == :postlive
#       end
#     end
#
#   end
#
#   describe 'built' do
#     before do
#       @talk = FactoryGirl.build :talk
#     end
#
#     it 'has a valid factory' do
#       expect(@talk).to be_valid
#     end
#     it 'validates presence of title' do
#       @talk.title = nil
#       expect(@talk).to_not be_valid
#     end
#     it 'validates presence of starts_at_date' do
#       @talk.starts_at_date = nil
#       expect(@talk).to_not be_valid
#     end
#     it 'validates presence of starts_at_time' do
#       @talk.starts_at_time = nil
#       expect(@talk).to_not be_valid
#     end
#     it "validates presence of new_venue_title if venue_id is not set" do
#       @talk.venue = nil
#       expect(@talk).to_not be_valid
#     end
#     it "is valid when venue_id is not set but new_venue_title is set" do
#       @talk.venue = nil
#       @talk.new_venue_title = "Some title"
#       @talk.venue_user = FactoryGirl.create(:user)
#       expect(@talk).to be_valid
#     end
#     it "creates a venue on the fly if new_venue_title is set" do
#       @talk.venue_id = nil
#       @talk.new_venue_title = "Some title"
#       @talk.venue_user = FactoryGirl.create(:user)
#       @talk.save!
#       expect(@talk.venue.title).to eq("Some title")
#     end
#     it 'should store what is written to processed_at' do
#       @talk.processed_at = time = Time.zone.now
#       @talk.save!
#       @talk.reload
#       expect(@talk.processed_at).to eq(time)
#     end
#     # FIXME Hello future self, this will fail when run during daylight
#     # saving time. Sophia suggested to test with a time zone that
#     # doesn't have daylight saving time
#     it 'assembles starts_at correctly when saved' do
#       expect(Time.zone.name).to eq('Berlin')
#       @talk.starts_at_date = '1942-05-22' # local
#       @talk.starts_at_time = '12:42' # local
#       @talk.save!
#       expect(@talk.reload.starts_at.utc.strftime('%H:%M')).to eq('10:42')
#     end
#   end
#
#   describe 'related talk' do
#     it 'has a related talk' do
#       featured_talk = FactoryGirl.create :talk
#       related_talk = FactoryGirl.create :talk
#
#       featured_talk.related_talk = related_talk
#       featured_talk.save
#
#       related_talk.reload.featured_talk.should eq(featured_talk)
#     end
#     context 'next talk' do
#       before do
#         @talk = FactoryGirl.create :talk
#       end
#       it 'returns nil when there is no next talk' do
#         @talk.venue.talks.count.should eq(1)
#         @talk.next_talk.should be_nil
#       end
#
#       it 'returns the next talk' do
#         @talk.venue.talks << FactoryGirl.create(:talk, title: 'first')
#         @talk.venue.talks << FactoryGirl.create(:talk, title: 'second')
#         @talk.venue.talks << FactoryGirl.create(:talk, title: 'third')
#
#         @talk.next_talk.title.should                     == 'first'
#         @talk.next_talk.next_talk.title.should           == 'second'
#         @talk.next_talk.next_talk.next_talk.title.should == 'third'
#       end
#     end
#   end
#
#   describe 'on class level' do
#     it 'has a scope featured' do
#       talk0 = FactoryGirl.create(:talk, featured_from: 2.days.ago, state: :prelive)
#       talk1 = FactoryGirl.create(:talk, featured_from: 1.day.ago, state: :live)
#       talk2 = FactoryGirl.create(:talk, featured_from: 1.day.from_now, state: :prelive)
#       expect(Talk.featured).to eq([talk1, talk0])
#       expect(Talk.featured).to include(talk0)
#     end
#
#     describe 'saves the Content-Type' do
#       before { @talk = FactoryGirl.create(:talk) }
#       it 'works for m4a' do
#         pending 'find a way to spec the mime type hack "m4a -> audio/mp4"'
#         m4a_file = File.expand_path("spec/support/fixtures/transcode0/1.m4a", Rails.root)
#         @talk.send(:upload_file, '1.m4a', m4a_file)
#
#         media_storage = Storage.directories.new(key: Settings.storage.media, prefix: @talk.uri)
#         media_storage.files.get('1.m4a').content_type.should == 'audio/mp4'
#       end
#       it 'works for mp3' do
#         mp3_file = File.expand_path("spec/support/fixtures/transcode0/1.mp3", Rails.root)
#         @talk.send(:upload_file, '1.mp3', mp3_file)
#
#         media_storage = Storage.directories.new(key: Settings.storage.media, prefix: @talk.uri)
#         media_storage.files.get('1.mp3').content_type.should == 'audio/mpeg'
#       end
#       it 'works for ogg' do
#         ogg_file = File.expand_path("spec/support/fixtures/transcode0/1.ogg", Rails.root)
#         @talk.send(:upload_file, '1.ogg', ogg_file)
#
#         media_storage = Storage.directories.new(key: Settings.storage.media, prefix: @talk.uri)
#         media_storage.files.get('1.ogg').content_type.should == 'audio/ogg'
#       end
#     end
#
#   end
#
#   describe 'created' do
#     before do
#       @talk = FactoryGirl.create(:talk)
#     end
#     it 'sets the time of starts_at via starts_at_time' do
#       @talk.starts_at_time = '12:34'
#       @talk.save
#       @talk.starts_at.strftime('%H:%M').should eq('12:34')
#     end
#     it 'sets the date of starts_at via starts_at_date' do
#       @talk.starts_at_date = '2013-12-31'
#       @talk.save
#       @talk.starts_at.strftime('%Y-%m-%d').should eq('2013-12-31')
#     end
#     it 'computes starts_in for use in prelive' do
#       expect(@talk.starts_in).to eq((@talk.starts_at - Time.now).to_i)
#     end
#   end
#
#   it 'nicely follows the life cycle' do
#     Delayed::Worker.delay_jobs = true # activate
#     VCR.use_cassette 'talk_dummy' do
#       talk = FactoryGirl.create(:talk)
#       expect(talk.current_state).to be(:prelive)
#       talk.start_talk!
#       expect(talk.current_state).to be(:live)
#       talk.end_talk!
#       expect(talk.current_state).to be(:postlive)
#       talk.process!
#       expect(talk.current_state).to be(:processing)
#       talk.archive!
#       expect(talk.current_state).to be(:archived)
#     end
#     Delayed::Worker.delay_jobs = false # deactivate
#   end
#
#   # NOTE: times set in a factory are not affected by `Timecop.freeze`
#   # in a before block
#   it 'provides a method starts_in' do
#     attrs = { starts_at_date: 1.hour.from_now.strftime('%Y-%m-%d') }
#     talk = FactoryGirl.create(:talk, attrs)
#     expect(talk.starts_in).to be > 0
#   end
#
#   it 'generate ephemeral paths' do
#     talk = FactoryGirl.create(:talk)
#     url = talk.generate_ephemeral_path!
#     expect(url).to match(/^http.*\.mp3$/)
#   end
#
#   it 'does not send email with option no_emails' do
#     ActionMailer::Base.deliveries = []
#     venue = FactoryGirl.create(:venue, options: { no_email: true })
#     talk = FactoryGirl.create(:talk, venue: venue)
#     ActionMailer::Base.deliveries.should be_empty
#   end
#
#   # TODO resolve code duplication in this section
#   describe 'nicely processes audio' do
#
#     it 'in state postlive', slow: true do
#       talk = FactoryGirl.create(:talk, collect: true)
#
#       # move fixtures in place
#       fixbase = File.expand_path("../../support/fixtures/talk_a", __FILE__)
#       fixglob = "#{fixbase}/*.flv"
#       fixflvs = Dir.glob(fixglob)
#       target = File.expand_path(Settings.rtmp.recordings_path, Rails.root)
#       flvs = fixflvs.map { |f| f.sub(fixbase, target).sub("t1-", "t#{talk.id}-") }
#       fixflvs.each_with_index { |fixflv, idx| FileUtils.cp(fixflv, flvs[idx]) }
#
#       # prepare talk
#       t_base = flvs.map { |f| f.match(/-(\d+)\./)[1].to_i }
#       talk.update_attribute :started_at, Time.at(t_base.min).to_datetime
#       talk.update_attribute :ended_at, Time.at(t_base.max + 1).to_datetime
#       talk.update_current_state :postlive, true
#
#       # run
#       VCR.use_cassette 'talk_postprocess' do
#         talk.send :postprocess!
#       end
#
#       # assert
#       base = File.expand_path(Settings.fog.storage.local_root, Rails.root)
#       result = File.join(base, Settings.storage.media,
#                          talk.uri, talk.id.to_s + '.m4a')
#       expect(File.exist?(result)).to be_true
#     end
#
#     it 'in state archived', slow: true do
#       talk = FactoryGirl.create(:talk, collect: true)
#
#       # move fixtures in place
#       fixbase = File.expand_path("../../support/fixtures/talk_a", __FILE__)
#       fixglob = "#{fixbase}/*.flv"
#       fixflvs = Dir.glob(fixglob)
#       target = File.expand_path(Settings.rtmp.recordings_path, Rails.root)
#       flvs = fixflvs.map { |f| f.sub(fixbase, target).sub("t1-", "t#{talk.id}-") }
#       fixflvs.each_with_index { |fixflv, idx| FileUtils.cp(fixflv, flvs[idx]) }
#
#       # prepare talk
#       t_base = flvs.map { |f| f.match(/-(\d+)\./)[1].to_i }
#       talk.update_attribute :started_at, Time.at(t_base.min).to_datetime
#       talk.update_attribute :ended_at, Time.at(t_base.max + 1).to_datetime
#       talk.update_current_state :postlive, true
#       VCR.use_cassette 'talk_postprocess' do
#         talk.send :postprocess!
#       end
#       base = File.expand_path(Settings.fog.storage.local_root, Rails.root)
#       result = File.join(base, Settings.storage.media,
#                          talk.uri, talk.id.to_s + '.m4a')
#       ctime = File.ctime(result)
#
#       # no we are in state `archived`, so we can do a `reprocess`
#       VCR.use_cassette 'talk_reprocess' do
#         talk.send :reprocess!
#       end
#
#       # assert
#       expect(File.ctime(result)).not_to eq(ctime)
#     end
#
#     it 'in state archived with override', slow: true do
#       talk = FactoryGirl.create(:talk, collect: true)
#
#       # move fixtures in place
#       fixbase = File.expand_path("../../support/fixtures/talk_a", __FILE__)
#       fixglob = "#{fixbase}/*.flv"
#       fixflvs = Dir.glob(fixglob)
#       target = File.expand_path(Settings.rtmp.recordings_path, Rails.root)
#       flvs = fixflvs.map { |f| f.sub(fixbase, target).sub("t1-", "t#{talk.id}-") }
#       fixflvs.each_with_index { |fixflv, idx| FileUtils.cp(fixflv, flvs[idx]) }
#
#       # prepare talk
#       t_base = flvs.map { |f| f.match(/-(\d+)\./)[1].to_i }
#       talk.update_attribute :started_at, Time.at(t_base.min).to_datetime
#       talk.update_attribute :ended_at, Time.at(t_base.max + 1).to_datetime
#       talk.update_current_state :postlive, true
#       VCR.use_cassette 'talk_postprocess' do
#         talk.send :postprocess!
#       end
#       base = File.expand_path(Settings.fog.storage.local_root, Rails.root)
#       result = File.join(base, Settings.storage.media,
#                          talk.uri, talk.id.to_s + '.m4a')
#       ctime = File.ctime(result)
#       # all of these should work, but for speed we only resort to the local file
#       override = 'https://staging.voicerepublic.com/sonar.ogg'
#       override = 'https://www.dropbox.com/s/z5sur3qt65xybav/testfoo.wav'
#       override = File.expand_path('spec/support/fixtures/sonar.ogg', Rails.root)
#       talk.update_attribute :recording_override, override
#
#       # no we are in state `archived`, so we can do a `process_override`
#       VCR.use_cassette 'talk_override' do
#         talk.send :process_override!
#       end
#
#       # assert
#       expect(File.ctime(result)).not_to eq(ctime)
#       expect(talk.recording_override).not_to eq(override)
#     end
#
#   end
#
#   describe 'nicely handles callbacks' do
#
#     it 'running after_start' do
#       pending 'Please write a spec, pretty please!'
#     end
#
#     it 'running after_end' do
#       pending 'Please write a spec, pretty please!'
#     end
#
#   end
#
#   describe 'with indexing' do
#     before do
#       Thread.current["PgSearch.enable_multisearch"] = true
#       @talk = FactoryGirl.create :talk
#     end
#
#     after do
#       Thread.current["PgSearch.enable_multisearch"] = false
#     end
#
#     it 'properly limits fields' do
#       # if the cumulated lengths of all indexed fields is to long
#       # this will raise an error
#       expect do
#         @talk.title       = '-' * Settings.limit.string
#         @talk.teaser      = '-' * Settings.limit.string
#         @talk.description = '-' * Settings.limit.text
#         @talk.save!
#       end.to_not raise_error
#     end
#   end
#
# end
