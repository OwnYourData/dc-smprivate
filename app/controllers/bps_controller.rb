class BpsController < ApplicationController
    
    include ApplicationHelper
    include StoresHelper

    def aggregate
        id = params[:id]
        @orig_store = Store.find(id)
        item = @orig_store.item
        if item.is_a?(String)
            item = JSON.parse(item)
        end
        @fix_store = Store.find(29) # !!!fix-me
        meta = @fix_store.meta
        if meta.is_a?(String)
            meta = JSON.parse(meta) rescue {}
        end
        if !meta.is_a?(Hash)
            meta = {}
        end
        response_nil = false

        if meta["async-id"].nil?
            # prepare request
            dpps = []
            item["usedMaterial"].each do |el|
                srvs = Oydid.read(el["concreteDppDid"], {}).first["doc"]["doc"]["service"] rescue []
                srvs.each do |srv|
                    if srv["type"] == "ProductPassport"
                        begin
                            response = HTTParty.get(srv["serviceEndpoint"])
                        rescue => ex
                            response_nil = true
                        end
                        if !response_nil && response.code == 200
                            dpps << {
                                did: el["concreteDppDid"], 
                                dpp_vp: response
                            }
                        end
                    end
                end
            end

            # send request to ZKP service
            response_nil = false
            body = {
                definition: item,
                dpps: dpps
            }
            zkp_url = ZKP_HOST + '/creation?snark=true'
            response_nil = false
            begin
                response = HTTParty.post(zkp_url, 
                    headers: { 'Content-Type' => 'application/json' },
                    body: body.to_json )
            rescue => ex
                response_nil = true
            end
        else
            # check status for ZKP service request
            zkp_url = ZKP_HOST + '/creation/' + meta["async-id"].to_s
            begin
                response = HTTParty.get(zkp_url)
            rescue => ex
                response_nil = true
            end
        end

        if response_nil || response.code != 200
            if response.code == 202 && !response_nil
                meta["async-id"] = response["id"].to_s rescue {}
                @fix_store.meta = meta
                @fix_store.save
                render json: {"error": "ZKP generation started, click 'Aggregate BuildingPart' again to get status updates."},
                       status: 500
            else
                render json: {"error": "cannot generate ZKP"},
                       status: 500
            end
            return
        end
        if response["state"] == "Complete"
            response_nil = false
            zkp_url = ZKP_HOST + '/creation/' + meta["async-id"].to_s + '/result'
            begin
                response = HTTParty.get(zkp_url)
            rescue => ex
                response_nil = true
            end
            if response_nil || response.code != 200
                render json: {"error": "cannot generate EPD"},
                       status: 500
                return
            end

            @fix_store.meta = {}
            @fix_store.save

            retVal = write_item(response, {}, "ZkBuildingPartEPD", nil, nil)
            retVal = write_item({did: nil, vp: nil, epd: response}, {}, "BuildingPartDPP", nil, nil)

            render plain: '',
                   status: 200
        elsif response["state"] == "Inprogress"
            render json: {"error": "ZKP generation in progress, click 'Generate EPD' again to get status updates."},
                   status: 500
        else
            render json: {"error": "cannot generate EPD"},
                   status: 500
        end

    end

    def generate
        @store = Store.find(params[:id]) rescue nil?
        if @store.nil?
            render json: {"error": "id not found"},
                   status: 404
            return
        end

        # since VC/VP does not work yet, just build it on our own
        # credential = @store.item["credential"]
        # payload = JWT.decode(@store.item["credential"], nil, false)
        content = @store.item["epd"]
        options = {}
        options[:issuer] = ENV['ISSUER_DID'] # abstract "Issuer"
        options[:issuer_privateKey] = Oydid.generate_private_key(ENV['HOLDER_PWD'].to_s, 'ed25519-priv', {}).first
        options[:holder] = ENV['HOLDER_DID'] # holder is the Construction Site Manager
        vc, msg = Oydid.create_vc(content, options)

        options[:holder_privateKey] = Oydid.generate_private_key(ENV['HOLDER_PWD'].to_s, 'ed25519-priv', {}).first
        vp, msg = Oydid.create_vp(JSON.parse(vc.to_json), options)

        options[:location] = DISP_HOST
        retVal, msg = Oydid.publish_vp(vp, options)
        content = {
            service: [{
                id: "#product",
                type: "ProductPassport",
                serviceEndpoint: retVal
            }, {
                id: "#info",
                type: "EPD",
                data: content
            }]
        }
        item = @store.item
        item["vp"] = retVal.to_s
        retVal, msg = Oydid.create(content,{})
        item["did"] = retVal["did"].to_s
        @store.item = item
        @store.save
        render json: {did: retVal["did"]},
               status: 200
    end
end
