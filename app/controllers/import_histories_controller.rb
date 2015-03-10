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
end
