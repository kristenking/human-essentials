require 'rails_helper'

RSpec.describe "/partners/requests", type: :request do
  describe "GET #index" do
    subject { -> { get partners_requests_path } }
    let(:partner_user) { partner.primary_user }
    let(:partner) { create(:partner) }
    let(:item1) { create(:item, name: "First item") }
    let(:item2) { create(:item, name: "Second item") }

    before do
      sign_in(partner_user)
    end

    it 'should render without any issues' do
      subject.call
      expect(response).to render_template(:index)
    end

    it 'should display total count of items in partner request' do
      create(
        :request,
        partner_id: partner.id,
        partner_user_id: partner_user.id,
        request_items: [
          {item_id: item1.id, quantity: '125'},
          {item_id: item2.id, quantity: '559'}
        ]
      )
      subject.call
      expect(response.body).to include("684")
    end
  end

  describe "GET #new" do
    subject { -> { get new_partners_request_path } }
    let(:partner_user) { partner.primary_user }
    let(:partner) { create(:partner) }

    before do
      sign_in(partner_user)
    end

    it 'should render without any issues' do
      subject.call
      expect(response).to render_template(:new)
    end
  end

  describe "GET #show" do
    let(:partner_user) { partner.primary_user }
    let(:partner) { create(:partner) }
    let!(:request) { create(:request, partner: partner) }

    before do
      sign_in(partner_user)
    end

    it 'should render without any issues' do
      get partners_request_path(request)
      expect(response.body).to include(request.id.to_s)
    end

    it 'should give a 404 error if not found' do
      id = Request.last.id + 1
      get partners_request_path(id)
      expect(response.code).to eq("404")
    end

    it 'should give a 404 error if forbidden' do
      other_partner = FactoryBot.create(:partner)
      other_request = FactoryBot.create(:request, partner: other_partner)
      get partners_request_path(other_request)
      expect(response.code).to eq("404")
    end
  end

  describe "POST #create" do
    subject { -> { post partners_requests_path, params: { request: request_attributes } } }
    let(:request_attributes) do
      {
        comments: Faker::Lorem.paragraph,
        item_requests_attributes: {
          "0" => {
            item_id: Item.all.sample.id,
            quantity: Faker::Number.within(range: 4..13)
          }
        }
      }
    end
    let(:partner_user) { partner.primary_user }
    let(:partner) { create(:partner) }

    before do
      sign_in(partner_user)
    end

    context 'when given valid parameters' do
      let(:request_attributes) do
        {
          comments: Faker::Lorem.paragraph,
          item_requests_attributes: {
            "0" => {
              item_id: Item.all.sample.id,
              quantity: Faker::Number.within(range: 4..13)
            }
          }
        }
      end

      it 'should redirect to the show page' do
        subject.call
        expect(response).to redirect_to(partners_request_path(Request.last.id))
      end
    end

    context 'when given invalid parameters' do
      let(:request_attributes) do
        {
          comments: ""
        }
      end

      it 'should not redirect' do
        subject.call
        expect(response).to render_template(:new)
      end
    end
  end
end
