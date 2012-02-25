require 'spec_helper'

describe BusStop do

  use_vcr_cassette :record => :new_episodes

  let(:base_data) do
    {
      :lat          => (rand() * 360 - 180),
      :lng          => (rand() * 180 - 90),
      :stop_number  => (rand() * 90000 + 10000),
      :display_name => "Example Test Stop",
      :description  => "Stop of Doom"
    }.tap { |d| d[:gtfs_id] = d[:stop_number] }
  end
  
  context 'validations' do

    it 'should require a stop number' do
      stop = BusStop.new(base_data.except(:stop_number))
      stop.should_not be_valid
      stop.should have(1).errors_on(:stop_number)
      stop.stop_number = '12345'
      stop.should be_valid
    end

    it 'should require a gtfs id' do
      stop = BusStop.new(base_data.except(:gtfs_id))
      stop.should_not be_valid
      stop.should have(1).errors_on(:gtfs_id)
      stop.gtfs_id = 12345
      stop.should be_valid
    end

  end

  it 'should allow you to get a compact version' do
    stop = BusStop.create(base_data.merge(:stop_number => 10000))
    serialized = stop.serializable_hash :compact => true
    serialized.keys.should =~ %w(id stop_number display_name description lat lng compact)
    serialized['compact'].should be_true
    serialized['stop_number'].should be_present
  end

  it 'should allow you to get a full version' do
    stop = BusStop.create(base_data.merge(:stop_number => 10000))
    serialized = stop.serializable_hash
    serialized.keys.should =~ %w(id stop_number display_name description lat lng times)
    serialized['times'].should be_present
    serialized['stop_number'].should be_present
  end

  it 'should let you fetch times for busses' do
    stop = BusStop.create(base_data.merge(:stop_number => 10000))
    times = stop.times
    times.should be_present
    times.each do |time|
      time.should be_a TransperthClient::BusTime
    end
  end

  it 'should use the stop number for the slug' do
    stop = BusStop.create(base_data.merge(:stop_number => 10000))
    BusStop.find_using_slug!('10000').should == stop
  end

  it 'should let you import bus stops' do
    mock(BusStop).create.with_any_args.times(any_times)
    BusStop.import!
  end

end