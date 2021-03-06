require "rails_helper"

RSpec.describe Farmers::NotificationsController, type: :controller do
  describe "#index" do
    context "with notifications" do
      let(:farmer) { FactoryGirl.create(:farmer, :with_notifications) }
      before do
        sign_in farmer
      end

      it "should set correct variables" do
        get :index
        expect(assigns(:unseen_notifications)).not_to be_nil
        expect(assigns(:notifications)).not_to be_nil
      end
    end

    context "without notifications" do
      let(:farmer) { FactoryGirl.create(:farmer) }
      before do
        sign_in farmer
        farmer.notifications.update_all unseen: false
      end

      it "should set correct values to variables" do
        get :index
        expect(assigns(:unseen_notifications)).to eq(false)
        expect(assigns(:notifications)).to be_empty
      end
    end
  end
end
