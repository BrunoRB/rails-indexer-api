require 'open-uri'

class PagesController < ApplicationController
  include JSONAPI::ActsAsResourceController

  # https://jsonapi.org/examples/#error-objects-basics
  def _sendError(err, code=400)
    render json: {errors: [{'status' => code, 'title' => err}]}, status: code
  end

  def create
    # puts request.headers.env
    # return
    begin
      if !params[:data] || !params[:data][:attributes]
        self._sendError('Missing parameters')
        return
      elsif !params[:data][:attributes][:url]
        self._sendError('Missing URL')
        return
      elsif !params[:data][:type] || params[:data][:type] != 'pages'
        self._sendError('Invalid TYPE')
        return
      end

      url = params['data']['attributes']['url']
      if !URI.regexp(['http', 'https']).match(url)
        self._sendError('Invalid URL')
        return
      end

      htmlStr = !Rails.env.test? ?
        open(url).read :
        params['data']['attributes']['pageHTML'] # fake page html so we can test the endpoint

      values = []
      doc = Nokogiri::HTML(htmlStr)

      ActiveRecord::Base.transaction do

        page = Page.find_by(url: url)
        if !page || !page.id
          page = Page.new(url: url)
          page.save!
        else
          # for pre-existing urls we delete all indexed content, then insert the fresh data (an update)
          # p Indexed.methods
          Indexed.where(['pages_id=?', page.id]).delete_all()
        end

        # bulk insert
        values.concat doc.css('h1,h2,h3').map {|node| [node.name, node.content.strip, page.id]}
        values.concat URI.extract(htmlStr).map {|s| ['link', s, page.id]}
        Indexed.import [:c_type, :content, :pages_id], values, :validate => true

        render json: JSONAPI::ResourceSerializer.new(PageResource).serialize_to_hash(PageResource.new(page, nil))
      end
    rescue StandardError => e
      self._sendError e.message
    end
  end
end
