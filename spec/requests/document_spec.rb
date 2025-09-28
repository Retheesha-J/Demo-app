require 'rails_helper'

RSpec.describe "Documents",type: :request do
    let(:user){ create(:user)}
    let(:file_path){Rails.root.join("spec/fixtures/files/test_file.txt")}
    let(:uploaded_file){fixture_file_upload(file_path,"text/plain")}

    before do
        sign_in user
    end

    describe "POSTS /documents" do
        context "with valid parameters" do
            it "uploads a file successfully" do
                expect{
                    post documents_path, params:{ document:{title:"test",file:uploaded_file}}
            }.to change(user.documents,:count).by(1)

            expect(response).to redirect_to(documents_path)
            follow_redirect!
            expect(response.body).to include("Document uploaded successfully")
            document= user.documents.last
            expect(document.file).to be_attached
            end
        end
        
        context "with valid parameters" do
            it "does not upload file without title" do
                expect{
                    post documents_path, params:{ document:{title:"",file:uploaded_file}}
            }.not_to change(user.documents,:count)

                expect(response).to have_http_status(:unprocessable_entity)
                assert_select "span.text-red-600", text: "can't be blank"
            end
        end
    end

    describe "GET /documents/:id/download" do
        let!(:document){create(:document,user:user,title:"test",file:uploaded_file)}
        
        context "when file exists" do
            it "download the  file" do
                get download_document_path(document)
                expect(response).to redirect_to(rails_blob_url(document.file,disposition:"attachment"))
            end
        end

        context "when file is not attached" do
            before do
                document.file.purge
            end

            it "redirects with alert" do
                get download_document_path(document)
                expect(response).to redirect_to(documents_path)
                follow_redirect!
                expect(response.body).to include("File not found.")
            end
        end
    end
end
