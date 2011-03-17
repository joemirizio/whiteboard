require 'spec_helper'

describe SponsoredProjectEffortsController do

  context "as faculty do" do

    before do
      @faculty_frank = Factory(:faculty_frank)
      UserSession.create(@faculty_frank)
    end

    describe "GET index" do
      before(:each) do
        @effort_mock = mock_model(SponsoredProjectEffort)
        SponsoredProjectEffort.stub(:find).and_return([@effort_mock, @effort_mock])
        get :index
      end

      it 'assigns @efforts' do
        assigns(:efforts).should == [@effort_mock, @effort_mock]
      end
    end

    describe "GET edit" do

      it 'assigns @efforts' do
        efforts = [stub_model(SponsoredProjectEffort)]
        SponsoredProjectEffort.should_receive(:current_months_efforts_for_user).with(@faculty_frank.id).and_return(efforts)
        get :edit, :id => @faculty_frank.twiki_name
        assigns(:efforts).should == efforts
      end
    end

    describe "PUT update" do

      before(:each) do
        @effort_1 = stub_model(SponsoredProjectEffort)
        @effort_2 = stub_model(SponsoredProjectEffort)

        @effort_1.stub(:valid).and_return(true)
        @effort_2.stub(:valid).and_return(true)

        @effort_1.stub(:unique_month_year_allocation_id?).and_return(true)
        @effort_2.stub(:unique_month_year_allocation_id?).and_return(true)

        SponsoredProjectEffort.should_receive(:find).with("0").and_return(@effort_1)
        SponsoredProjectEffort.should_receive(:find).with("1").and_return(@effort_2)

        subject.should_receive(:setup_edit).and_return(true)
      end


      describe "with valid params" do

        it "updates the actual allocations" do
          @effort_1.should_receive(:actual_allocation=).with("25")
          @effort_2.should_receive(:actual_allocation=).with("75")
          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
        end
  
        it 'updates the confirmed value' do
          @effort_1.should_receive(:confirmed=).with(true)
          @effort_2.should_receive(:confirmed=).with(true)
          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
        end

#        it 'sets the flash' do
#          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
#          flash.now[:notice].should_not be_nil
#        end

        it "re-renders the 'edit' template" do
          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
          response.should render_template("edit")
        end
      end

      describe "with invalid params" do

        it 'sets the flash to error' do
          @effort_2.should_receive(:save).and_return(false)
          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
          assigns[:failed].should == true
          #flash.now[:error].should == "Your allocations did not save."
        end

        it "re-renders the 'edit' template" do
          @effort_2.should_receive(:save).and_return(false)
          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
          response.should render_template("edit")
        end
      end
    end
  end

end