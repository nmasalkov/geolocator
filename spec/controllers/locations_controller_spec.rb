# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationsController, type: :controller do
  describe 'GET #index' do
    let(:expected_pagination_data) do
      {
        total_pages: total_pages,
        total_count: 20
      }.with_indifferent_access
    end

    before { create_list(:location, 20) }

    context 'without pagination' do
      let(:page) { 1 }
      let(:per_page) { 10 }
      let(:total_pages) { 2 }

      it 'returns records with default pagination params' do
        get :index

        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect(response_data['locations'].count).to eq(10)
        expect(response_data['pagination']).to eq(expected_pagination_data)
      end
    end

    context 'with "page":2, "per_page":5 pagination params' do
      let(:page) { 2 }
      let(:per_page) { 5 }
      let(:total_pages) { 4 }

      it 'returns the second page of records' do
        get :index, params: { page: page, per_page: per_page }

        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect(response_data['locations'].count).to eq(5)
        expect(response_data['pagination']).to eq(expected_pagination_data)
      end
    end

    context 'with invalid pagination params' do
      let(:error_response) do
        {
          errors: {
            page: ['must be an integer'],
            per_page: ['must be greater than or equal to 1']
          }
        }.with_indifferent_access
      end

      it 'returns error response' do
        get :index, params: { page: 'invalid', per_page: -12 }

        expect(response).to have_http_status(:unprocessable_entity)
        response_data = JSON.parse(response.body)
        expect(response_data).to eq(error_response)
      end
    end
  end

  describe 'GET #show' do
    let(:existing_location) { create(:location) }

    context 'when record exists' do
      let(:expected_location) do
        {
          id: existing_location.id,
          ip_address: existing_location.ip_address,
          url: existing_location.url,
          longitude: existing_location.longitude,
          latitude: existing_location.latitude
        }.with_indifferent_access
      end

      it 'returns location' do
        get :show, params: { id: existing_location.id }

        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect(response_data).to eq(expected_location)
      end
    end

    context "when record doesn't exist" do
      it 'returns error message' do
        get :show, params: { id: (existing_location.id + 1000) }

        expect(response).to have_http_status(:not_found)
        response_data = JSON.parse(response.body)
        expect(response_data).to eq({ errors: ['location not found'] }.with_indifferent_access)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:existing_location) { create(:location) }

    it 'deletes the location' do
      delete :destroy, params: { id: existing_location.id }

      expect(response).to have_http_status(:success)
      expect(Location.find_by(id: existing_location.id)).to be_nil
    end

    context "when record doesn't exist" do
      it 'returns error message' do
        get :show, params: { id: (existing_location.id + 1000) }

        expect(response).to have_http_status(:not_found)
        response_data = JSON.parse(response.body)
        expect(response_data).to eq({ errors: ['location not found'] }.with_indifferent_access)
      end
    end
  end

  describe 'GET #find' do
    let(:searched_location) { create(:location) }

    context 'without search_string param' do
      it 'returns an error message' do
        get :find

        expect(response).to have_http_status(:unprocessable_entity)
        response_data = JSON.parse(response.body)
        expect(response_data).to eq({ errors: { search_string: ['is missing'] } }.with_indifferent_access)
      end
    end

    context 'with search_string param' do
      context 'when location is found' do
        let(:expected_location) do
          {
            id: searched_location.id,
            ip_address: searched_location.ip_address,
            url: searched_location.url,
            longitude: searched_location.longitude,
            latitude: searched_location.latitude
          }.with_indifferent_access
        end

        it 'returns the location' do
          get :find, params: { search_string: searched_location.url }

          expect(response).to have_http_status(:success)
          response_data = JSON.parse(response.body)
          expect(response_data).to eq(expected_location)
        end
      end

      context 'when location is not found' do
        it 'returns an error message' do
          get :find, params: { search_string: 'non_existent_url' }

          expect(response).to have_http_status(:not_found)
          response_data = JSON.parse(response.body)
          expect(response_data).to eq({ errors: ['location not found'] }.with_indifferent_access)
        end
      end
    end
  end

  describe 'POST #create' do
    let(:valid_latitude) { 45.1234 }
    let(:valid_longitude) { -120.5678 }
    let(:valid_ip) { '192.168.1.1' }

    context 'without source param' do
      it 'returns an error message' do
        post :create

        expect(response).to have_http_status(:unprocessable_entity)
        response_data = JSON.parse(response.body)
        expect(response_data).to eq({ errors: { source: ['is missing'],
                                                type: ['is missing'] } }.with_indifferent_access)
      end
    end

    context 'with an invalid URL' do
      it 'returns an error message' do
        post :create, params: { source: 'invalid_url', type: 'url' }

        expect(response).to have_http_status(:unprocessable_entity)
        response_data = JSON.parse(response.body)
        expect(response_data).to eq({ errors: {
          source: ['We could not parse your url. Please check that the link is valid']
        } }.with_indifferent_access)
      end
    end

    context 'with an invalid IP address' do
      it 'returns an error message' do
        post :create, params: { source: 'invalid_ip', type: 'ip_address' }

        expect(response).to have_http_status(:unprocessable_entity)
        response_data = JSON.parse(response.body)
        expect(response_data).to eq({ errors: { source: ['IP is invalid'] } }.with_indifferent_access)
      end
    end

    context 'when ipstack fails' do
      before do
        allow(Ipstack).to receive_message_chain(:new, :find_location).and_return(nil)
      end

      context 'when geocoder provides coordinates' do
        before do
          allow_any_instance_of(CoordinatesFinder).to receive(:geocoder_response).and_return(
            latitude: valid_latitude,
            longitude: valid_longitude
          )
        end

        it 'saves location' do
          post :create, params: { source: valid_ip, type: 'ip_address' }

          expect(response).to have_http_status(:created)
          created_location = Location.last

          expect(created_location.ip_address).to eq(valid_ip)
          expect(created_location.latitude).to eq(valid_latitude)
          expect(created_location.longitude).to eq(valid_longitude)
        end
      end

      context 'when ipstack and geocoder both fail' do
        before do
          allow_any_instance_of(CoordinatesFinder).to receive(:geocoder_response).and_return(nil)
        end

        it 'returns an error message' do
          post :create, params: { source: valid_ip, type: 'ip_address' }

          expect(response).to have_http_status(:unprocessable_entity)
          response_data = JSON.parse(response.body)
          expect(response_data['message']).to eq('unable to locate IP address')
        end
      end
    end

    context 'when coordinates are OK' do
      before do
        allow_any_instance_of(CoordinatesFinder).to receive(:call).and_return(
          latitude: valid_latitude,
          longitude: valid_longitude
        )
      end

      context 'when record was not saved' do
        context 'with active model errors' do
          let!(:existing_location) { create(:location, ip_address: valid_ip) }
          let(:message) do
            'Location was detected, but we were unable to save it because of:' \
                                ' Ip address has already been taken'
          end

          it 'renders location without saving' do
            post :create, params: { source: valid_ip, type: 'ip_address' }
            response_data = JSON.parse(response.body)
            expect(response).to have_http_status(:ok)
            expect(response_data['message']).to eq(message)
            expect(Location.count).to eq(1)
          end
        end

        context 'with db timeout' do
          let(:message) { 'Location was detected, but we were unable to save it' }

          before do
            allow_any_instance_of(Location).to receive(:save)
              .and_raise(ActiveRecord::StatementInvalid.new('Database connection timeout'))
          end

          it 'renders location without saving' do
            post :create, params: { source: valid_ip, type: 'ip_address' }
            response_data = JSON.parse(response.body)
            expect(response).to have_http_status(:ok)
            expect(response_data['message']).to eq(message)
            expect(Location.count).to eq(0)
          end
        end
      end
    end
  end
end
