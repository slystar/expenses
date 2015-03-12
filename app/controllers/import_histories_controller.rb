class ImportHistoriesController < ApplicationController
    before_filter :login_required

    # Index
    def index
	@ihs=ImportHistory.includes(:user).includes(:import_config).all
    end
    
    # Show
    def show
	@ih=ImportHistory.includes(:user).includes(:import_config).find(params[:id])
    end

    # DELETE imported records
    def delete_imported_records
	# Get records
	ih = ImportHistory.find(params[:id])
	# Get current user_id
	user_id=session[:user_id]
	# Delete records
	if ih.delete_imported_records(user_id)
	    redirect_to "#{request.referer}", notice: "Errased all imported records for ImportHistory id:#{ih.id}"
	else
	    redirect_to "#{request.referer}", alert: ih.errors.messages[:base].first
	end
    end
end
