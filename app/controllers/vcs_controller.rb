class VcsController < ApplicationController
    
    include ApplicationHelper
    include StoresHelper

    def accept
        puts params.to_json
        id = params[:id]
        @vc_store = Store.find(id) rescue nil
        if @vc_store.nil?
            render json: {"error": "Record ID '#{id}' not found"},
                   status: 404
            return
        end

        # publish credential
        options = {}
        options[:location] = VC_HOST
        vc = @vc_store.item
        retVal, msg = Oydid.publish_vc(vc, options)
        if msg.to_s != ""
            render json: {"error": msg},
                   status: 500
            return
        end

        # write record with schema 'ConcreteDelivery'
        if vc.is_a?(String)
            vc = JSON.parse(vc)
        end
        cd = vc["credentialSubject"].reject { |key, _| key == "id" }
        cd["vc"] = retVal
        retVal = write_item(cd, {}, "ConcreteDelivery", nil, nil)

        @vc_store.destroy
        render plain: '',
               status: 200
    end
end
