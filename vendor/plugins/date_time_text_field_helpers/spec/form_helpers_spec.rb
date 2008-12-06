require File.dirname(__FILE__) + '/spec_helper'

describe DateTimeTextFieldHelpers::FormHelpers do
  
  before do
    self.stub!(:params).and_return({})
  end

  describe "date_text_field helper" do
    before do
      @person = mock('Person', :date_of_birth => nil) 
    end
    
    it "should output a span with 3 text field tags" do
      output = date_text_field(:person, :date_of_birth)
      output.should have_tag('span.date_time_field') do
        with_tag('input[type=text]', 3)
        with_tag('input[type=text][id=person_date_of_birth_1i][class=year_field][name=?]', 'person[date_of_birth(1i)]')
        with_tag('input[type=text][id=person_date_of_birth_2i][class=month_field][name=?]', 'person[date_of_birth(2i)]')
        with_tag('input[type=text][id=person_date_of_birth_3i][class=day_field][name=?]', 'person[date_of_birth(3i)]')
      end
    end
    
    it "should output a text fields with todays date as default with leading zeroes when column value nil" do
      output = date_text_field(:person, :date_of_birth)
      date = Time.now.to_date
      output.should have_tag('input[id=person_date_of_birth_1i][value=?]', date.year)
      output.should have_tag('input[id=person_date_of_birth_2i][value=?]', date.month.to_s.rjust(2, '0'))
      output.should have_tag('input[id=person_date_of_birth_3i][value=?]', date.day.to_s.rjust(2, '0')) 
    end
    
    it "should output a text fields with column value with leading zeroes" do
      @person.stub!(:date_of_birth).and_return(Date.new(1950, 2, 1))
      output = date_text_field(:person, :date_of_birth)
      output.should have_tag('input[id=person_date_of_birth_1i][value=?]', 1950)
      output.should have_tag('input[id=person_date_of_birth_2i][value=?]', '02')
      output.should have_tag('input[id=person_date_of_birth_3i][value=?]', '01') 
    end

    it "should output empty text fields when column value nil and option :blank => true" do
      output = date_text_field(:person, :date_of_birth, :blank => true)
      output.should have_tag('input[id=person_date_of_birth_1i][value=?]', nil)
      output.should have_tag('input[id=person_date_of_birth_2i][value=?]', nil)
      output.should have_tag('input[id=person_date_of_birth_3i][value=?]', nil) 
    end

    it "should output text fields using default order of year, month, day" do
      output = date_text_field(:person, :date_of_birth)
      output.should have_tag('input.year_field ~ input.month_field ~ input.day_field')
    end
    
    it "should output text fields using order option" do
      output = date_text_field(:person, :date_of_birth, :order => [:day, :month, :year])
      output.should have_tag('input.day_field ~ input.month_field ~ input.year_field')
    end
    
    it "should output text fields separated by default separator" do
      output = date_text_field(:person, :date_of_birth)
      output.should match(/(\/> - <input.*?){2}/)
    end
    
    it "should output text fields separated by separator from options" do      
      output = date_text_field(:person, :date_of_birth, :date_separator => '/')
      output.should match(/(\/> \/ <input.*?){2}/)
    end    
  end
  
  describe "time_text_field helper" do  
    before do
      @person = mock('Person', :time_of_birth => nil)
    end
    it "should output a span with 2 text field tags and 3 hidden fields for date parts" do      
      output = time_text_field(:person, :time_of_birth)
      output.should have_tag('span.date_time_field') do
        with_tag('input[type=text]', 2)
        with_tag('input[type=text][id=person_time_of_birth_4i][class=hour_field][name=?]', 'person[time_of_birth(4i)]')
        with_tag('input[type=text][id=person_time_of_birth_5i][class=minute_field][name=?]', 'person[time_of_birth(5i)]')
        with_tag('input[type=hidden]', 3)
        with_tag('input[type=hidden][id=person_time_of_birth_1i]')
        with_tag('input[type=hidden][id=person_time_of_birth_2i]')
        with_tag('input[type=hidden][id=person_time_of_birth_3i]')
      end      
    end
  
    it "should output a span with 3 text field tags with option :include_seconds => true" do
      output = time_text_field(:person, :time_of_birth, :include_seconds => true)
      output.should have_tag('span.date_time_field') do
        with_tag('input[type=text]', 3)
        with_tag('input[type=text][id=person_time_of_birth_4i][class=hour_field][name=?]', 'person[time_of_birth(4i)]')
        with_tag('input[type=text][id=person_time_of_birth_5i][class=minute_field][name=?]', 'person[time_of_birth(5i)]')
        with_tag('input[type=text][id=person_time_of_birth_6i][class=second_field][name=?]', 'person[time_of_birth(6i)]')
      end      
    end    
    
    it "should output a text fields with current time as default with leading zeroes when column value nil" do
      output = time_text_field(:person, :time_of_birth, :include_seconds => true)
      time = Time.now
      output.should have_tag('input[id=person_time_of_birth_4i][value=?]', time.hour.to_s.rjust(2, '0'))
      output.should have_tag('input[id=person_time_of_birth_5i][value=?]', time.min.to_s.rjust(2, '0'))
      output.should have_tag('input[id=person_time_of_birth_6i][value=?]', time.sec.to_s.rjust(2, '0')) 
    end
    
    it "should output a text fields with column value with leading zeroes" do
      @person.stub!(:time_of_birth).and_return(Time.local(2000, 1, 1, 1, 2, 3))
      output = time_text_field(:person, :time_of_birth, :include_seconds => true)      
      output.should have_tag('input[id=person_time_of_birth_4i][value=?]', '01')
      output.should have_tag('input[id=person_time_of_birth_5i][value=?]', '02')
      output.should have_tag('input[id=person_time_of_birth_6i][value=?]', '03') 
    end

    it "should output empty text fields when column value nil and option :blank => true" do
      output = time_text_field(:person, :time_of_birth, :include_seconds => true, :blank => true)
      date = Time.now.to_date
      output.should have_tag('input[id=person_time_of_birth_4i][value=?]', nil)
      output.should have_tag('input[id=person_time_of_birth_5i][value=?]', nil)
      output.should have_tag('input[id=person_time_of_birth_6i][value=?]', nil) 
    end
    
    it "should output a fields separated by default separator" do
      output = time_text_field(:person, :time_of_birth)
      output.should match(/\/> : <input/)
    end
    
    it "should output a fields separated by separator from options" do
      output = time_text_field(:person, :time_of_birth, :time_separator => '.')
      output.should match(/\/> . <input/)
    end
  end
  
  describe "datetime_text_field helper" do
    before do
      @person = mock('Person', :date_and_time_of_birth => nil)
    end
    
    it "should output a span with 5 text field tags" do
      output = datetime_text_field(:person, :date_and_time_of_birth)
      output.should have_tag('span.date_time_field') do
        with_tag('input[type=text]', 5)
        with_tag('input[type=text][id=person_date_and_time_of_birth_1i][class=year_field][name=?]', 'person[date_and_time_of_birth(1i)]')
        with_tag('input[type=text][id=person_date_and_time_of_birth_2i][class=month_field][name=?]', 'person[date_and_time_of_birth(2i)]')
        with_tag('input[type=text][id=person_date_and_time_of_birth_3i][class=day_field][name=?]', 'person[date_and_time_of_birth(3i)]')
        with_tag('input[type=text][id=person_date_and_time_of_birth_4i][class=hour_field][name=?]', 'person[date_and_time_of_birth(4i)]')
        with_tag('input[type=text][id=person_date_and_time_of_birth_5i][class=minute_field][name=?]', 'person[date_and_time_of_birth(5i)]')
      end
    end
    
    it "should output a span with 6 text field tags with option include_seconds => true" do
      output = datetime_text_field(:person, :date_and_time_of_birth, :include_seconds => true)
      output.should have_tag('span.date_time_field') do
        with_tag('input[type=text]', 6)
        with_tag('input[type=text][id=person_date_and_time_of_birth_6i][class=second_field][name=?]', 'person[date_and_time_of_birth(6i)]')
      end 
    end

    it "should output a text fields with current time as default with leading zeroes when column value nil" do
      output = datetime_text_field(:person, :date_and_time_of_birth, :include_seconds => true)
      time = Time.now
      output.should have_tag('input[id=person_date_and_time_of_birth_1i][value=?]', time.year)
      output.should have_tag('input[id=person_date_and_time_of_birth_2i][value=?]', time.month.to_s.rjust(2, '0'))
      output.should have_tag('input[id=person_date_and_time_of_birth_3i][value=?]', time.day.to_s.rjust(2, '0')) 
      output.should have_tag('input[id=person_date_and_time_of_birth_4i][value=?]', time.hour.to_s.rjust(2, '0'))
      output.should have_tag('input[id=person_date_and_time_of_birth_5i][value=?]', time.min.to_s.rjust(2, '0'))
      output.should have_tag('input[id=person_date_and_time_of_birth_6i][value=?]', time.sec.to_s.rjust(2, '0')) 
    end
    
    it "should output date and time part separated by default separator" do
      output = datetime_text_field(:person, :date_and_time_of_birth)
      output.should match(/\/> &mdash; <input/)
    end
    
    it "should output date and time fields separated by separator from options" do
      output = datetime_text_field(:person, :date_and_time_of_birth, :date_time_separator => ',')
      output.should match(/\/> , <input/)
    end    
  end
  
  describe "redisplay values from params hash" do
    before do
      @person = mock('Person', :date_of_birth => nil) 
    end
    
    it "should use values from params hash as input values for fields" do
      self.stub!(:params).and_return({"person" => {"date_of_birth(1i)" => 2008, "date_of_birth(2i)" => 2, "date_of_birth(3i)" => 1} } )
      output = date_text_field(:person, :date_of_birth)
      output.should have_tag('input[id=person_date_of_birth_1i][value=?]', 2008)
      output.should have_tag('input[id=person_date_of_birth_2i][value=?]', 2)
      output.should have_tag('input[id=person_date_of_birth_3i][value=?]', 1) 
    end
  end
end
